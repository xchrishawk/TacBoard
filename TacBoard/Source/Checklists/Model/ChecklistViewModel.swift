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
    private let userContentManager: UserContentManager
    private let settingsManager: SettingsManager
    
    private let mutablePrimaryDataIndex: MutableProperty<ChecklistDataIndex>
    private let mutablePrimaryDataIndexSource: MutableProperty<ContentSource>
    private let mutableSecondaryDataIndices: MutableProperty<[ChecklistDataIndex]>
    
    private let mutableAllBinders: MutableProperty<[ChecklistBinder]>
    private let mutableDisplayedBinders: MutableProperty<[ChecklistBinder]>
    
    private let isCompleteLookup: MutableProperty<[String: Set<DataIndexKey>]>
    private var isCompleteDisposable: CompositeDisposable?
    private var isCompleteLookupPurged: Bool
    
    // MARK: Initialization / Singleton
    
    /// The shared instance of the `ChecklistViewModel` class.
    static let shared = ChecklistViewModel()
    
    /// Initializes a new instance with the specified settings manager.
    init(contentManager: ContentManager = ContentManager.shared,
         userContentManager: UserContentManager = UserContentManager.shared,
         settingsManager: SettingsManager = SettingsManager.shared) {
    
        // Managers
        self.contentManager = contentManager
        self.userContentManager = userContentManager
        self.settingsManager = settingsManager
        
        // Misc
        self.mutablePrimaryDataIndex = MutableProperty(ChecklistDataIndex.fallback)
        self.mutablePrimaryDataIndexSource = MutableProperty(.fallback)
        self.mutableSecondaryDataIndices = MutableProperty([])
        self.mutableAllBinders = MutableProperty([])        // initialized in initializeBindings()
        self.mutableDisplayedBinders = MutableProperty([])  // initialized in initializeBindings()
        
        // Persisted properties
        self.enabledAircraftModules = Property(settingsManager.enabledAircraftModules)
        self.splitDisplayMode = settingsManager.checklistSplitDisplayMode
        self.isCompleteLookup = settingsManager.checklistIsCompleteLookup
        
        // Temporary properties
        self.primaryDataIndex = Property(self.mutablePrimaryDataIndex)
        self.primaryDataIndexSource = Property(self.mutablePrimaryDataIndexSource)
        self.secondaryDataIndices = Property(self.mutableSecondaryDataIndices)
        self.allBinders = Property(self.mutableAllBinders)
        self.displayedBinders = Property(self.mutableDisplayedBinders)
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

    /// The currently active primary checklist data index.
    let primaryDataIndex: Property<ChecklistDataIndex>
    
    /// The data source for the currently active primary checklist data index.
    let primaryDataIndexSource: Property<ContentSource>
    
    /// The currently active secondary checklist data indices.
    let secondaryDataIndices: Property<[ChecklistDataIndex]>
    
    /// The collection of all available checklist binders, regardless of filter settings.
    let allBinders: Property<[ChecklistBinder]>
    
    /// The collection of currently displayed checklist binders, based on the current filter settings.
    let displayedBinders: Property<[ChecklistBinder]>
    
    /// The currently selected procedure.
    let selectedItem: MutableProperty<ChecklistProcedure?>
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
        
        // Reload data index when the content manager source changes
        contentManager.source.producer.take(during: lifetime).startWithValues { [unowned self] source in
            self.loadPrimaryDataIndex(from: source)
        }
        
        // Also reload when commanded
        contentManager.reloadContent.take(during: lifetime).observeValues { [unowned self] in
            self.loadPrimaryDataIndex(from: self.contentManager.source.value)
        }
        
        // Handle book-keeping when the primary data index changes
        primaryDataIndex.producer.startWithValues { [unowned self] primaryDataIndex in
            self.processNewDataIndex(primaryDataIndex)
        }
        
        // Update secondary data indices with user checklists
        mutableSecondaryDataIndices <~ userContentManager.checklists.map { $0.map { $0.object } }
        
        // Handle book-keeping when the secondary data indices change
        secondaryDataIndices.producer.startWithValues { [unowned self] secondaryDataIndices in
            for secondaryDataIndex in secondaryDataIndices {
                self.processNewDataIndex(secondaryDataIndex)
            }
        }
        
        // Update the `allBinders` property based on the current data indices
        let allBindersProducer = SignalProducer.combineLatest(primaryDataIndex.producer, secondaryDataIndices.producer)
        mutableAllBinders <~ allBindersProducer.map { (primaryDataIndex, secondaryDataIndices) in
            return primaryDataIndex.objects + secondaryDataIndices.reduce(into: []) { $0.append(contentsOf: $1.objects) }
        }
        
        // Update the `displayedBinders` property based on the current filter settings
        let displayedBindersProducer = SignalProducer.combineLatest(allBinders.producer, enabledAircraftModules.producer)
        mutableDisplayedBinders <~ displayedBindersProducer.map { (allBinders, enabledAircraftModules) in
            return allBinders.filter { binder in
                guard let aircraftModule = binder.aircraftModule else { return true }
                return enabledAircraftModules.contains(aircraftModule)
            }
        }
        
        // Reset the displayed checklist if it's not contained in the available binders
        displayedBinders.producer.startWithValues { [unowned self] displayedBinders in
            guard let selectedItem = self.selectedItem.value else { return }
            if !displayedBinders.contains(where: { $0.contains(item: selectedItem) }) {
                
                // First, try to find a checklist with a key matching the old selected item
                for binder in displayedBinders {
                    if let item = binder.firstItem(where: { $0.key == selectedItem.key }) {
                        self.selectedItem.value = item
                        return
                    }
                }
                
                // If that fails, then reset the selected checklist to nil
                self.selectedItem.value = nil
                
            }
        }
        
        // If the selected checklist is nil and the display mode is set to hide the menu, then switch it back
        // to show to prevent the menu from unexpectedly disappearing when the user selects something
        selectedItem.producer.startWithValues { [unowned self] selectedItem in
            if selectedItem == nil, self.splitDisplayMode.value == .hide {
                self.splitDisplayMode.value = .show
            }
        }
        
    }

    /// Loads checklist data from the specified content source.
    private func loadPrimaryDataIndex(from source: ContentSource) {
        ChecklistDataIndex.load(source: source) { [weak self] result in
            
            guard case .success(let primaryDataIndex) = result else { return }
            
            self?.mutablePrimaryDataIndex.value = primaryDataIndex
            self?.mutablePrimaryDataIndexSource.value = source
            
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
            return key == primaryDataIndex.value.key
        }
        
    }
    
}
