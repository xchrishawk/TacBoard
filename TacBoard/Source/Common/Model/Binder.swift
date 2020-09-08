//
//  Binder.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/15/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift

// MARK: - BinderItem

/// Typealias for objects which can be an item for `Binder` and `Folder`.
typealias BinderItem = Decodable & Equatable

// MARK: - BinderViewModel

/// Protocol for view models containing binder information.
protocol BinderViewModel {
    
    // MARK: Types
    
    /// The item type associated with this view model.
    associatedtype Item: BinderItem
    
    // MARK: Properties
    
    /// The currently available binders.
    var binders: Property<[Binder<Item>]> { get }
    
    /// The currently selected item.
    var selectedItem: MutableProperty<Item?> { get }
    
}

// MARK: - Binder

/// Abstract base class representing a binder of items.
class Binder<Item>: Decodable, ReferenceEquatable where Item: BinderItem {

    // MARK: Initialization
    
    /// Initializes a new instance with the specified values.
    init(title: String? = nil, aircraftModule: AircraftModule? = nil, terrainModule: TerrainModule? = nil, folders: [Folder<Item>] = []) {
        self.title = title ?? aircraftModule?.title ?? terrainModule?.title
        self.aircraftModule = aircraftModule
        self.terrainModule = terrainModule
        self.folders = folders
    }
    
    // MARK: Properties
    
    /// The title for this binder.
    let title: String?
    
    /// The aircraft module with which this binder is associated, if any.
    let aircraftModule: AircraftModule?
    
    /// The terrain module with which this binder is associated, if any.
    let terrainModule: TerrainModule?
    
    /// The folders contained in this binder.
    let folders: [Folder<Item>]
    
    // MARK: Methods
    
    /// Returns `true` if this binder contains the specified folder.
    func contains(folder: Folder<Item>) -> Bool {
        return folders.contains { $0 == folder || $0.contains(folder: folder) }
    }
    
    /// Returns `true` if this binder contains the specified item.
    func contains(item: Item) -> Bool {
        return folders.contains { $0.contains(item: item) }
    }
    
    /// Returns the first `Item` in this binder's folders which matches the specified `predicate`.
    func firstItem(where predicate: (Item) -> Bool) -> Item? {
     
        // Search all folders
        for folder in folders {
            if let item = folder.firstItem(where: predicate) {
                return item
            }
        }
        
        return nil
        
    }
    
    // MARK: Codable
    
    /// `CodingKey` enum for this class.
    private enum CodingKeys: String, CodingKey {
        case title
        case aircraftModule
        case terrainModule
        case folders
    }
    
    /// Initializes a new instance with the specified `Decoder`.
    convenience required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Aircraft module needs special handling
        let aircraftModule: AircraftModule? = try {
            
            guard
                let aircraftModuleKey = try container.decodeOrDefault(String?.self, forKey: .aircraftModule, default: nil)
                else { return nil }
            
            guard
                let aircraftModule = AircraftModule.for(key: aircraftModuleKey)
                else { throw DecodingError.dataCorruptedError(forKey: .aircraftModule, in: container, debugDescription: "Invalid aircraft module!") }
            
            return aircraftModule
            
        }()
        
        // Terrain module too
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
                  aircraftModule: aircraftModule,
                  terrainModule: terrainModule,
                  folders: try container.decodeOrDefault([Folder<Item>].self, forKey: .folders, default: []))
        
    }
    
}
