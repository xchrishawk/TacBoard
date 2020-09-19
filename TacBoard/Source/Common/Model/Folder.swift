//
//  Folder.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/15/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Abstract base class for objects representing a "folder" of sub-items.
class Folder<Item>: Decodable, ReferenceEquatable where Item: BinderItem {
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified values.
    init(key: DataIndexKey, title: String, subfolders: [Folder<Item>], items: [Item] = []) {
        
        self.key = key
        self.title = title
        self.subfolders = subfolders
        self.items = items
        
    }

    // MARK: Properties
    
    /// A unique key for this folder.
    let key: DataIndexKey
    
    /// The title of this folder.
    let title: String
    
    /// The subfolders contained by this folder.
    let subfolders: [Folder<Item>]
    
    /// The items contained in this folder.
    let items: [Item]
    
    /// The total number of items contained in this folder and all of its subfolders.
    lazy var itemCount: Int = {
        return items.count + subfolders.reduce(0) { $0 + $1.itemCount }
    }()
    
    // MARK: Methods
    
    /// Returns `true` if this folder (or any of its subfolders) contains the specified folder.
    func contains(folder: Folder<Item>) -> Bool {
        return subfolders.contains { $0 == folder || $0.contains(folder: folder) }
    }
    
    /// Returns `true` if this folder (or any of its subfolders) contains the specified item.
    func contains(item: Item) -> Bool {
        return items.contains { $0 == item || subfolders.contains { $0.contains(item: item) } }
    }
    
    /// Returns the first `Item` contained in this folder or its subfolders which matches `predicate`.
    func firstItem(where predicate: (Item) -> Bool) -> Item? {
    
        // First search our own items
        for item in items {
            if predicate(item) {
                return item
            }
        }
        
        // Then recursively search subfolders
        for subfolder in subfolders {
            if let item = subfolder.firstItem(where: predicate) {
                return item
            }
        }
        
        // If those both fail, return nil
        return nil
        
    }
    
    // MARK: Decodable
    
    /// `CodingKey` enum for this class.
    private enum CodingKeys: String, CodingKey {
        case title
        case subfolders
        case items
    }
    
    /// Initializes a new instance with the specified `Decoder`.
    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(key: DataIndex<Binder<Item>>.key(for: decoder),
                  title: try container.decode(String.self, forKey: .title),
                  subfolders: try container.decodeOrDefault([Folder<Item>].self, forKey: .subfolders, default: []),
                  items: try container.decodeOrDefault([Item].self, forKey: .items, default: []))
    }
    
}
