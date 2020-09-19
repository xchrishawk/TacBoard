//
//  AirportViewModel.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/4/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift
import UIKit

/// View model for the airport page.
class AirportViewModel {
    
    // MARK: Fields
    
    private let (lifetime, token) = Lifetime.make()
    
    private let contentManager: ContentManager
    private let settingsManager: SettingsManager
    
    private let mutablePrimaryDataIndex: MutableProperty<AirportDataIndex>
    private let mutablePrimaryDataIndexSource: MutableProperty<ContentSource>
    private let mutableSecondaryDataIndices: MutableProperty<[AirportDataIndex]>

    private let mutableAllCollections: MutableProperty<[AirportCollection]>
    private let mutableDisplayedCollections: MutableProperty<[AirportCollection]>
    
    // MARK: Initialization
    
    /// The shared instance of the `AirportViewModel` class.
    static let shared = AirportViewModel()
    
    /// Initializes a new instance with the specified managers.
    init(contentManager: ContentManager = ContentManager.shared,
         settingsManager: SettingsManager = SettingsManager.shared) {
        
        // Managers
        self.contentManager = contentManager
        self.settingsManager = settingsManager
        
        // Misc
        self.mutablePrimaryDataIndex = MutableProperty(AirportDataIndex.fallback)
        self.mutablePrimaryDataIndexSource = MutableProperty(.fallback)
        self.mutableSecondaryDataIndices = MutableProperty([])
        self.mutableAllCollections = MutableProperty([])        // initialized in initializeBindings()
        self.mutableDisplayedCollections = MutableProperty([])  // initialized in initializeBindings()
        
        // Persisted properties
        self.enabledTerrainModules = Property(settingsManager.enabledTerrainModules)
        self.unitFormat = Property(settingsManager.unitFormat)
        self.latLonFormat = Property(settingsManager.latLonFormat)
        self.splitDisplayMode = settingsManager.airportSplitDisplayMode
        self.darkModeBrightness = settingsManager.airportDarkModeBrightness
        
        // Temporary properties
        self.primaryDataIndex = Property(self.mutablePrimaryDataIndex)
        self.primaryDataIndexSource = Property(self.mutablePrimaryDataIndexSource)
        self.secondaryDataIndices = Property(self.mutableSecondaryDataIndices)
        self.allCollections = Property(self.mutableAllCollections)
        self.displayedCollections = Property(self.mutableDisplayedCollections)
        self.selectedAirport = MutableProperty(nil)
        self.searchText = MutableProperty(nil)
        
        initializeBindings()
        
    }
    
    // MARK: Properties
    
    /// The currently enabled terrain modules.
    let enabledTerrainModules: Property<Set<TerrainModule>>
    
    /// The unit format to use.
    let unitFormat: Property<UnitFormat>
    
    /// The latitude/longitude format to use.
    let latLonFormat: Property<LatLon.Format>
    
    /// The split display mode.
    let splitDisplayMode: MutableProperty<SplitDisplayMode>
    
    /// The currently active primary airport data index.
    let primaryDataIndex: Property<AirportDataIndex>
    
    /// The source for the currently active primary airport data index.
    let primaryDataIndexSource: Property<ContentSource>
    
    /// The currently active secondary airport data indices.
    let secondaryDataIndices: Property<[AirportDataIndex]>
    
    /// An array of all available airport collections, regardless of filter settings.
    let allCollections: Property<[AirportCollection]>

    /// An array of the currently displayed airport collections, based on filter settings.
    let displayedCollections: Property<[AirportCollection]>
    
    /// The currently selected airport.
    let selectedAirport: MutableProperty<Airport?>
    
    /// The text to use to filter the airport results.
    let searchText: MutableProperty<String?>
    
    /// The brightness to use for images in dark mode.
    let darkModeBrightness: MutableProperty<CGFloat>
    
    // MARK: Methods
    
    /// Returns a `UIImage` for the specified `AirportImage`.
    /// - note: Callback is guaranteed to be called on the main thread.
    func image(for airportImage: AirportImage, completion: @escaping (UIImage?) -> Void) {
        switch airportImage.location {
            
        case .asset(let asset):
            
            // Display the image from the local asset
            guard let image = UIImage(named: asset) else { fatalInvalidResource() }
            completion(image)
            
        case .relative(let path):
            
            let url = contentManager.url(forRelativePath: path)
            if url.isFileURL {
                
                // File is a local URL
                guard let image = UIImage(contentsOfFile: url.path) else { fatalInvalidResource() }
                completion(image)
                
            } else {
                
                // File is a remote URL. Create task to download the remote file
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    
                    // Get image from result, if possible
                    let image: UIImage? = {
                        
                        guard
                            error == nil,
                            let httpResponse = response as? HTTPURLResponse,
                            httpResponse.isStatusCodeOK,
                            let data = data,
                            let image = UIImage(data: data)
                            else { return nil }
                        
                        return image
                        
                    }()
                    
                    // Jump back to main thread
                    DispatchQueue.main.async { completion(image) }
                    
                }
                
                // Start the task
                task.resume()
                
            }
            
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
        
        // Update the `allCollections` property based on the current data indices
        let allCollectionsProducer = SignalProducer.combineLatest(primaryDataIndex.producer, secondaryDataIndices.producer)
        mutableAllCollections <~ allCollectionsProducer.map { (primaryDataIndex, secondaryDataIndices) in
            return primaryDataIndex.objects + secondaryDataIndices.reduce(into: []) { $0.append(contentsOf: $1.objects) }
        }
        
        // Update the `displayedCollections` property based on the current filter settings
        let displayedCollectionsProducer = SignalProducer.combineLatest(allCollections.producer, enabledTerrainModules.producer, searchText.producer)
        mutableDisplayedCollections <~ displayedCollectionsProducer.map { (allCollections, enabledTerrainModules, searchText) in
            return allCollections.compactMap { collection in
                
                // Only display collections for enabled modules
                if let terrainModule = collection.terrainModule {
                    guard enabledTerrainModules.contains(terrainModule) else { return nil }
                }
                
                // Return a copy of the aircraft collection with all non-matching airports filtered out
                return AirportCollection(key: collection.key, title: collection.title, terrainModule: collection.terrainModule, airports: collection.airports.filter { airport in
                    
                    guard let searchText = searchText, !searchText.isEmpty else { return true }
                    
                    return (airport.identifier.localizedCaseInsensitiveContains(searchText) ||
                        airport.name.localizedCaseInsensitiveContains(searchText) ||
                        (airport.callsign?.localizedCaseInsensitiveContains(searchText) ?? false))
                    
                })
                
            }.filter { !$0.airports.isEmpty }
        }
        
        // Reset the displayed airport if it's not contained in the available collections
        displayedCollections.producer.startWithValues { [unowned self] displayedCollections in
            guard let selectedAirport = self.selectedAirport.value else { return }
            if !displayedCollections.contains(where: { $0.contains(airport: selectedAirport) }) {
                self.selectedAirport.value = nil
            }
        }
        
        // If the if selected airport is nil and the display mode is set to hide the menu, then switch it back
        // to show to prevent the menu from unexpectedly disappearing when the user selects something
        selectedAirport.producer.startWithValues { [unowned self] selectedAirport in
            if selectedAirport == nil, self.splitDisplayMode.value == .hide {
                self.splitDisplayMode.value = .show
            }
        }
        
    }

    /// Loads data from the specified content source.
    private func loadPrimaryDataIndex(from source: ContentSource) {
        AirportDataIndex.load(source: source) { [weak self] result in
            
            guard case .success(let primaryDataIndex) = result else { return }
            
            self?.mutablePrimaryDataIndex.value = primaryDataIndex
            self?.mutablePrimaryDataIndexSource.value = source
            
        }
    }

}
