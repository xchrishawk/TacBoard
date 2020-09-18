//
//  ChecklistViewModel.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift
import UIKit

/// View model for the checklist system.
class ChecklistViewModel: BinderViewModel {

    // MARK: Fields
    
    private let (lifetime, token) = Lifetime.make()
    
    private let contentManager: ContentManager
    private let settingsManager: SettingsManager
    
    private let mutableDataIndex: MutableProperty<ChecklistDataIndex>
    private let mutableDataIndexSource: MutableProperty<ContentSource>
    private let mutableBinders: MutableProperty<[ChecklistBinder]>
    
    private let isCompleteLookup: MutableProperty<[String: Set<DataIndexKey>]>
    private var isCompleteDisposable: CompositeDisposable?
    private var isCompleteLookupPurged: Bool
    
    // MARK: Initialization / Singleton
    
    /// The shared instance of the `ChecklistViewModel` class.
    static let shared = ChecklistViewModel()
    
    /// Initializes a new instance with the specified settings manager.
    init(contentManager: ContentManager = ContentManager.shared,
         settingsManager: SettingsManager = SettingsManager.shared) {
    
        // Managers
        self.contentManager = contentManager
        self.settingsManager = settingsManager
        
        // Misc
        self.mutableDataIndex = MutableProperty(ChecklistDataIndex.fallback)
        self.mutableDataIndexSource = MutableProperty(.fallback)
        self.mutableBinders = MutableProperty(self.mutableDataIndex.value.objects)
        
        // Persisted properties
        self.enabledAircraftModules = Property(settingsManager.enabledAircraftModules)
        self.splitDisplayMode = settingsManager.checklistSplitDisplayMode
        self.isCompleteLookup = settingsManager.checklistIsCompleteLookup
        
        // Temporary properties
        self.dataIndex = Property(self.mutableDataIndex)
        self.dataIndexSource = Property(self.mutableDataIndexSource)
        self.binders = Property(self.mutableBinders)
        self.selectedItem = MutableProperty(nil)
        
        // Utility
        self.isCompleteDisposable = nil
        self.isCompleteLookupPurged = false
        
        initializeBindings()
        
    }
    
    // MARK: Properties
    
    /// The currently enabled aircraft modules.
    let enabledAircraftModules: Property<Set<AircraftModule>>
    
    /// The split display mode.
    let splitDisplayMode: MutableProperty<SplitDisplayMode>

    /// The currently active checklist data index.
    let dataIndex: Property<ChecklistDataIndex>
    
    /// The data source for the currently active checklist data index.
    let dataIndexSource: Property<ContentSource>
    
    /// The collection of available checklist binders.
    let binders: Property<[ChecklistBinder]>
    
    /// The currently selected procedure.
    let selectedItem: MutableProperty<ChecklistProcedure?>
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
        
        // Reload data index when the content manager source changes
        contentManager.source.producer.take(during: lifetime).startWithValues { [unowned self] source in
            self.loadData(from: source)
        }
        
        // Also reload when commanded
        contentManager.reloadContent.take(during: lifetime).observeValues { [unowned self] in
            self.loadData(from: self.contentManager.source.value)
        }
        
        // Handle book-keeping when the data index changes
        dataIndex.producer.take(during: lifetime).startWithValues { [unowned self] dataIndex in
            self.processNewDataIndex(dataIndex)
        }
        
        // Filter the displayed checklists as needed
        let bindersProducer = SignalProducer.combineLatest(dataIndex.producer, enabledAircraftModules.producer)
        mutableBinders <~ bindersProducer.map { (dataIndex, enabledAircraftModules) in
            return dataIndex.objects.filter { binder in
                guard let aircraftModule = binder.aircraftModule else { return true }
                return enabledAircraftModules.contains(aircraftModule)
            }
        }
        
        // Reset the displayed checklist if it's not contained in the available binders
        binders.producer.startWithValues { [unowned self] _ in
            guard let selectedItem = self.selectedItem.value else { return }
            if !self.binders.value.contains(where: { $0.contains(item: selectedItem) }) {
                self.selectedItem.value = nil
            }
        }
        
        // If the selected checklist is nil and the display mode is set to hide the menu, then switch it back
        // to show to prevent the menu from unexpectedly disappearing when the user selects something
        selectedItem.producer.startWithValues { [unowned self] _ in
            if self.selectedItem.value == nil, self.splitDisplayMode.value == .hide {
                self.splitDisplayMode.value = .show
            }
        }
        
    }

    /// Loads checklist data from the specified content source.
    private func loadData(from source: ContentSource) {
        ChecklistDataIndex.load(source: source) { [weak self] result in
            
            guard case .success(let dataIndex) = result else { return }
            
            self?.mutableDataIndex.value = dataIndex
            self?.mutableDataIndexSource.value = source
            
            // The first time we load a non-fallback data source, purge the "is complete" lookup of old data
            if source != .fallback {
                self?.purgeIsCompleteLookup()
            }
            
        }
    }
    
    /// Handles a newly loaded data index.
    private func processNewDataIndex(_ dataIndex: ChecklistDataIndex) {
        
        // Release all previous subscriptions to the former data index
        isCompleteDisposable?.dispose()
        isCompleteDisposable = CompositeDisposable()

        /// Processes the specified `ChecklistFolder`, including all of its subfolders.
        func process(folder: ChecklistFolder) {
         
            // Loop through all top-level procedures
            for procedure in folder.items {
                for section in procedure.sections {
                    for item in section.items {

                        // This is only applicable to completable items
                        guard let completableItem = item as? ChecklistCompletableItem else { continue }
                        
                        // Get required tokens
                        let indexKey = dataIndex.key
                        let itemKey = completableItem.key
                        
                        // Initialize the completion state
                        completableItem.isComplete.value = isCompleteLookup.value[indexKey, default: []].contains(itemKey)
                        
                        // Now subscribe to any future changes
                        completableItem.isComplete.producer.skip(first: 1).take(during: lifetime).startWithValues { [unowned self] isComplete in
                            if isComplete {
                                isCompleteLookup.value[indexKey, default: []].insert(itemKey)
                            } else {
                                isCompleteLookup.value[indexKey]?.remove(itemKey)
                            }
                        }
                        
                    }
                }
            }
            
            // Now recursively update subfolders
            for subfolder in folder.subfolders {
                process(folder: subfolder)
            }
            
        }
        
        // Recursively process every folder in every binder
        for binder in dataIndex.objects {
            for folder in binder.folders {
                process(folder: folder)
            }
        }
        
    }
    
    /// Removes lookups for any checklists which are no longer present.
    private func purgeIsCompleteLookup() {
        
        // Only do this once per app lifetime
        guard !isCompleteLookupPurged else { return }
        defer { isCompleteLookupPurged = true }
        
        isCompleteLookup.value = isCompleteLookup.value.filter { (key, _) in
            return key == dataIndex.value.key
        }
        
    }
    
}
