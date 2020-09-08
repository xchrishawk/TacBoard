//
//  ChecklistCommentItem.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift

/// Object representing a non-checkable comment item in a checklist.
class ChecklistCommentItem: ChecklistItem, Decodable {
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified values.
    init(text: String, subtext: String? = nil, action: String? = nil, comment: String? = nil) {
        self.text = text
        self.subtext = subtext
        self.action = action
        self.comment = comment
    }
    
    // MARK: Properties
    
    /// The text of the item.
    let text: String
    
    /// The subtext of the item, or `nil` if there is no subtext.
    let subtext: String?
    
    /// The action for the user to take, or `nil` if there is no action.
    let action: String?
    
    /// The comment for this item, or `nil` if there is no comment.
    let comment: String?
    
    // MARK: Codable
    
    /// `CodingKey` enum for this class.
    private enum CodingKeys: String, CodingKey {
        case text
        case subtext
        case action
        case comment
    }
    
    /// Initializes a new instance with the specified `Decoder`.
    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(text: try container.decode(String.self, forKey: .text),
                  subtext: try container.decodeOrDefault(String?.self, forKey: .subtext, default: nil),
                  action: try container.decodeOrDefault(String?.self, forKey: .action, default: nil),
                  comment: try container.decodeOrDefault(String?.self, forKey: .comment, default: nil))
    }
    
}
