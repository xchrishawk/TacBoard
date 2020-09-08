//
//  AirportCollection.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/4/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

// MARK: - AirportDataIndex

/// Type representing a data index of airport collections.
typealias AirportDataIndex = DataIndex<AirportCollection>

extension DataIndex where Object: AirportCollection {
    
    // MARK: Class Methods
    
    /// The embedded fallback airport data index.
    static var fallback: AirportDataIndex {
        return AirportDataIndex.load(localURL: ContentManager.url(forRelativePath: relativePath, source: .fallback))
    }
    
    /// Asynchronously loads the airport data index from the specified content manager.
    /// - note: The completion block is guaranteed to be called on the main thread.
    static func load(source: ContentSource, completion: @escaping (AirportDataIndex?) -> Void) {
        AirportDataIndex.load(url: ContentManager.url(forRelativePath: relativePath, source: source), completion: completion)
    }
    
    // MARK: Private Utility
    
    /// The expected relative path for the airport index.
    private static var relativePath: String { return "AirportDataIndex.json" }
    
}

// MARK: - AirportCollection

/// Class representing the collection of airports in a specific terrain module.
class AirportCollection: Decodable {

    // MARK: Initialization
    
    /// Initializes a new instance with the specified values.
    init(title: String? = nil, terrainModule: TerrainModule? = nil, airports: [Airport]) {
        self.title = title ?? terrainModule?.title
        self.terrainModule = terrainModule
        self.airports = airports
    }
    
    // MARK: Properties
    
    /// The display title for this collection.
    let title: String?
    
    /// The terrain module with which this collection is associated.
    let terrainModule: TerrainModule?
    
    /// The airports located in this terrain.
    let airports: [Airport]
    
    // MARK: Methods
    
    /// Returns `true` if this collection contains the specified airport.
    func contains(airport: Airport) -> Bool {
        return airports.contains { $0 === airport }
    }
    
    // MARK: Codable
    
    /// `CodingKey` enum for this class.
    private enum CodingKeys: String, CodingKey {
        case title
        case terrainModule
        case airports
    }
    
    /// Initializes a new instance with the specified `Decoder`.
    convenience required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Terrain module needs special handling
        let terrainModule: TerrainModule? = try {
            
            guard
                let terrainModuleKey = try container.decodeOrDefault(String?.self, forKey: .terrainModule, default: nil)
                else { return nil }
            
            guard
                let terrainModule = TerrainModule.for(key: terrainModuleKey)
                else { throw DecodingError.dataCorruptedError(forKey: .terrainModule, in: container, debugDescription: "Invalid terrain module!") }
            
            return terrainModule
            
        }()
        
        self.init(title: try container.decodeOrDefault(String?.self, forKey: .title, default: nil),
                  terrainModule: terrainModule,
                  airports: try container.decode([Airport].self, forKey: .airports).sorted { $0.name < $1.name })
        
    }
    
}
