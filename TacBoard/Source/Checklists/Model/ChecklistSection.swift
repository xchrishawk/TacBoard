//
//  ChecklistSection.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift

/// Object representing an individual section in a checklist.
class ChecklistSection: Decodable {
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified values.
    init(title: String? = nil, items: [ChecklistItem] = []) {
        self.title = title
        self.items = items
    }
    
    // MARK: Properties
    
    /// The title of the section, or `nil` if there is no title.
    let title: String?
    
    /// The checklist items contained in the section.
    let items: [ChecklistItem]
    
    // MARK: Codable
    
    /// `CodingKey` enum for this class.
    private enum CodingKeys: String, CodingKey {
        case title
        case items
    }
    
    /// `CodingKey` enum for determining the type of each item.
    private enum ItemTypeKeys: String, CodingKey {
        case type
    }
    
    /// Enumeration of the known item types.
    private enum ItemType: String, Codable {
        case `default` = "Default"
        case comment = "Comment"
    }
    
    /// Initializes a new instance with the specified `Decoder`.
    convenience required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // We need two containers here - one to decode the type, and a second to decode the item itself.
        // We can't use the same container for both operations because decoding the type advances the iterator to the next item
        var itemsContainerForCheckingType = try container.nestedUnkeyedContainer(forKey: .items)
        var itemsContainerForDecodingItems = itemsContainerForCheckingType
        
        // Scan through the list of items
        var items = [ChecklistItem]()
        while !itemsContainerForCheckingType.isAtEnd {
         
            // Determine the type of this item
            let itemContainerForCheckingType = try itemsContainerForCheckingType.nestedContainer(keyedBy: ItemTypeKeys.self)
            let itemType = try itemContainerForCheckingType.decodeOrDefault(ItemType.self, forKey: .type, default: .default)
            
            // Append an item of the correct type based on the decoded type
            switch itemType {
            case .default:
                items.append(try itemsContainerForDecodingItems.decode(ChecklistDefaultItem.self))
            case .comment:
                items.append(try itemsContainerForDecodingItems.decode(ChecklistCommentItem.self))
            }
            
        }
        
        self.init(title: try container.decodeOrDefault(String?.self, forKey: .title, default: nil),
                  items: items)
        
    }

}
