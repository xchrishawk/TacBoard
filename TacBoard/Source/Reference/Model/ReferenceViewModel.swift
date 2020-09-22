//
//  ReferenceViewModel.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/15/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift
import UIKit

/// Main view model for the Reference section of the app.
class ReferenceViewModel: BinderViewModel {
    
    // MARK: Fields
    
    private let (lifetime, token) = Lifetime.make()
    
    private let contentManager: ContentManager
    private let settingsManager: SettingsManager
    
    private let mutablePrimaryDataIndex: MutableProperty<ReferenceDataIndex>
    private let mutablePrimaryDataIndexSource: MutableProperty<ContentSource>
    private let mutableSecondaryDataIndices: MutableProperty<[ReferenceDataIndex]>
    
    private let mutableAllBinders: MutableProperty<[ReferenceBinder]>
    private let mutableDisplayedBinders: MutableProperty<[ReferenceBinder]>
    
    // MARK: Initialization

    /// The shared instance of the `ReferenceViewModel` class.
    static let shared = ReferenceViewModel()
    
    /// Initializes a new instance with the specified settings manager.
    init(contentManager: ContentManager = ContentManager.shared,
         settingsManager: SettingsManager = SettingsManager.shared) {
        
        // Managers
        self.contentManager = contentManager
        self.settingsManager = settingsManager
        
        // Misc
        self.mutablePrimaryDataIndex = MutableProperty(ReferenceDataIndex.fallback)
        self.mutablePrimaryDataIndexSource = MutableProperty(.fallback)
        self.mutableSecondaryDataIndices = MutableProperty([])
        self.mutableAllBinders = MutableProperty([])        // initialized in initializeBindings()
        self.mutableDisplayedBinders = MutableProperty([])  // initialized in initializeBindings()
        
        // Persisted properties
        self.enabledAircraftModules = Property(settingsManager.enabledAircraftModules)
        self.enabledTerrainModules = Property(settingsManager.enabledTerrainModules)
        self.splitDisplayMode = settingsManager.referenceSplitDisplayMode
        self.darkModeBrightness = settingsManager.referenceDarkModeBrightness
     
        // Temporary properties
        self.primaryDataIndex = Property(self.mutablePrimaryDataIndex)
        self.primaryDataIndexSource = Property(self.mutablePrimaryDataIndexSource)
        self.secondaryDataIndices = Property(self.mutableSecondaryDataIndices)
        self.allBinders = Property(self.mutableAllBinders)
        self.displayedBinders = Property(self.mutableDisplayedBinders)
        self.selectedItem = MutableProperty(nil)
        
        initializeBindings()
        
    }
    
    // MARK: Properties
    
    /// The set of currently enabled aircraft modules.
    let enabledAircraftModules: Property<Set<AircraftModule>>
    
    /// The set of currently enabled terrain modules.
    let enabledTerrainModules: Property<Set<TerrainModule>>
    
    /// The split display mode.
    let splitDisplayMode: MutableProperty<SplitDisplayMode>
    
    /// The brightness to use for pages in dark mode.
    let darkModeBrightness: MutableProperty<CGFloat>
    
    /// The currently active primary reference documents data index.
    let primaryDataIndex: Property<ReferenceDataIndex>
    
    /// The content source for the currently active primary reference documents data index.
    let primaryDataIndexSource: Property<ContentSource>
    
    /// The currently active secondary reference document data indices.
    let secondaryDataIndices: Property<[ReferenceDataIndex]>
    
    /// The collection of all available reference document binders, regardless of filter settings.
    let allBinders: Property<[ReferenceBinder]>
    
    /// The collection of currently displayed reference document binders, based on the current filter settings.
    let displayedBinders: Property<[Binder<ReferenceDocument>]>
    
    /// The currently selected reference document.
    var selectedItem: MutableProperty<ReferenceDocument?>
    
    // MARK: Methods
    
    /// Returns the base URL for the current content source.
    var baseURL: URL {
        return contentManager.baseURL
    }
    
    /// Returns the URL for the specified path.
    func url(forRelativePath path: String) -> URL {
        return contentManager.url(forRelativePath: path)
    }
    
    /// Selects the reference document with the specified URL, if possible.
    func selectItem(at url: URL) {
        
        // Determine the relative path to search for
        let urlAbsoluteString = url.absoluteString
        let baseAbsoluteString = baseURL.absoluteString
        let relativePath = urlAbsoluteString.replacingOccurrences(of: baseAbsoluteString, with: String.empty)
        
        // Select the matching item, if we find one
        for binder in displayedBinders.value {
            
            guard let item = binder.firstItem(where: {
                guard case .relative(let itemRelativePath) = $0.location else { return false }
                return (itemRelativePath == relativePath)
            }) else { continue }
            
            selectedItem.value = item
            break
            
        }
        
    }
    
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
        
        // Update the `allBinders` property based on the current data indices
        let allBindersProducer = SignalProducer.combineLatest(primaryDataIndex.producer, secondaryDataIndices.producer)
        mutableAllBinders <~ allBindersProducer.map { (primaryDataIndex, secondaryDataIndices) in
            return primaryDataIndex.objects + secondaryDataIndices.reduce(into: []) { $0.append(contentsOf: $1.objects) }
        }
        
        // Update the `displayedBinders` property based on the current filter settings
        let displayedBindersProducer = SignalProducer.combineLatest(allBinders.producer, enabledAircraftModules.producer, enabledTerrainModules.producer)
        mutableDisplayedBinders <~ displayedBindersProducer.map { (allBinders, enabledAircraftModules, enabledTerrainModules) in
            return allBinders.filter { binder in
                
                // Filter by aircraft module
                if let aircraftModule = binder.aircraftModule {
                    guard enabledAircraftModules.contains(aircraftModule) else { return false }
                }
                
                // Filter by terrain module
                if let terrainModule = binder.terrainModule {
                    guard enabledTerrainModules.contains(terrainModule) else { return false }
                }
                
                // Otherwise, allow it
                return true
                
            }
        }
        
        // Reset the displayed document if it gets filtered out for any reason
        displayedBinders.producer.startWithValues { [unowned self] displayedBinders in
            guard let selectedItem = self.selectedItem.value else { return }
            if !displayedBinders.contains(where: { $0.contains(item: selectedItem) }) {
                
                // First, try to find a reference document with a key matching the old selected item
                for binder in displayedBinders {
                    if let item = binder.firstItem(where: { $0.key == selectedItem.key }) {
                        self.selectedItem.value = item
                        return
                    }
                }
                
                // If that fails, then reset the selected reference document to nil
                self.selectedItem.value = nil
                
            }
        }
        
        // If the selected item gets reset to nil, and the menu is currently set to hide, then display the menu
        selectedItem.producer.startWithValues { [unowned self] selectedItem in
            if selectedItem == nil, self.splitDisplayMode.value == .hide {
                self.splitDisplayMode.value = .show
            }
        }
        
    }

    /// Loads reference data from the specified content source.
    private func loadPrimaryDataIndex(from source: ContentSource) {
        ReferenceDataIndex.load(source: source) { [weak self] result in
            
            guard case .success(let primaryDataIndex) = result else { return }
            
            self?.mutablePrimaryDataIndex.value = primaryDataIndex
            self?.mutablePrimaryDataIndexSource.value = source
            
        }
    }
    
}
