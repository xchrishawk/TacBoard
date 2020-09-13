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
    
    private let mutableDataIndex: MutableProperty<ReferenceDataIndex>
    private let mutableDataIndexSource: MutableProperty<ContentSource>
    private let mutableBinders: MutableProperty<[ReferenceBinder]>
    
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
        self.mutableDataIndex = MutableProperty(ReferenceDataIndex.fallback)
        self.mutableDataIndexSource = MutableProperty(.fallback)
        self.mutableBinders = MutableProperty(self.mutableDataIndex.value.objects)
        
        // Persisted properties
        self.enabledAircraftModules = Property(settingsManager.enabledAircraftModules)
        self.enabledTerrainModules = Property(settingsManager.enabledTerrainModules)
        self.splitDisplayMode = settingsManager.referenceSplitDisplayMode
        self.darkModeBrightness = settingsManager.referenceDarkModeBrightness
     
        // Temporary properties
        self.dataIndex = Property(self.mutableDataIndex)
        self.dataIndexSource = Property(self.mutableDataIndexSource)
        self.binders = Property(self.mutableBinders)
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
    
    /// The currently active reference documents data index.
    let dataIndex: Property<ReferenceDataIndex>
    
    /// The content source for the currently active reference documents data index.
    let dataIndexSource: Property<ContentSource>
    
    /// The collection of available reference document binders.
    let binders: Property<[ReferenceBinder]>
    
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
        for binder in binders.value {
            
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
            self.loadData(from: source)
        }
        
        // Also reload when commanded
        contentManager.reloadContent.take(during: lifetime).observeValues { [unowned self] in
            self.loadData(from: self.contentManager.source.value)
        }
        
        // Filter the displayed reference documents as needed
        let bindersProducer = SignalProducer.combineLatest(dataIndex.producer, enabledAircraftModules.producer, enabledTerrainModules.producer)
        mutableBinders <~ bindersProducer.map { (dataIndex, enabledAircraftModules, enabledTerrainModules) in
            return dataIndex.objects.filter { binder in
                
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
        binders.producer.startWithValues { [unowned self] _ in
            guard let selectedItem = self.selectedItem.value else { return }
            if !self.binders.value.contains(where: { $0.contains(item: selectedItem) }) {
                self.selectedItem.value = nil
            }
        }
        
        // If the selected item gets reset to nil, and the menu is currently set to hide, then display the menu
        selectedItem.producer.startWithValues { [unowned self] _ in
            if self.selectedItem.value == nil, self.splitDisplayMode.value == .hide {
                self.splitDisplayMode.value = .show
            }
        }
        
    }

    /// Loads reference data from the specified content source.
    private func loadData(from source: ContentSource) {
        ReferenceDataIndex.load(source: source) { [weak self] dataIndex in
            
            guard
                let self = self,
                let dataIndex = dataIndex
                else { return }
            
            self.mutableDataIndex.value = dataIndex
            self.mutableDataIndexSource.value = source
            
        }
    }
    
}
