//
//  ChecklistDefaultItem.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift

/// Object representing a standard, checkable item in a checklist.
class ChecklistDefaultItem: ChecklistCompletableItem, Decodable {
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified values.
    init(key: DataIndexKey,
         text: NSAttributedString,
         subtext: String? = nil,
         action: String? = nil,
         comment: String? = nil,
         isComplete: Bool = false) {
        
        self.key = key
        self.text = text
        self.subtext = subtext
        self.action = action
        self.comment = comment
        self.isComplete = MutableProperty(isComplete)
        
    }
    
    // MARK: Properties
    
    /// A unique key for this checklist item.
    let key: DataIndexKey
    
    /// The text of the item.
    let text: NSAttributedString
    
    /// The subtext of the item, or `nil` if there is no subtext.
    let subtext: String?
    
    /// The action for the user to take, or `nil` if there is no action.
    let action: String?
    
    /// The comment for this item, or `nil` if there is no comment.
    let comment: String?
    
    /// If set to `true`, this checklist item has been completed.
    let isComplete: MutableProperty<Bool>
    
    // MARK: Codable
    
    /// `CodingKey` enum for this class.
    private enum CodingKeys: String, CodingKey {
        case text
        case subtext
        case action
        case comment
        case isComplete
    }
    
    /// Initializes a new instance with the specified `Decoder`.
    convenience required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard
            let textMarkup = try? container.decode(String.self, forKey: .text),
            let text = NSAttributedString(markup: textMarkup)
            else { throw DecodingError.dataCorruptedError(forKey: .text, in: container, debugDescription: "Invalid text!") }
        
        self.init(key: ChecklistDataIndex.key(for: decoder),
                  text: text,
                  subtext: try container.decodeOrDefault(String?.self, forKey: .subtext, default: nil),
                  action: try container.decodeOrDefault(String?.self, forKey: .action, default: nil),
                  comment: try container.decodeOrDefault(String?.self, forKey: .comment, default: nil),
                  isComplete: try container.decodeOrDefault(Bool.self, forKey: .isComplete, default: false))
        
    }
    
}
