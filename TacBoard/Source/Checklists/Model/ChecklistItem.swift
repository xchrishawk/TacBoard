//
//  ChecklistItem.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift

// MARK: - ChecklistItem

/// Protocol for objects representing items which may be displayed in a checklist.
protocol ChecklistItem: class, Decodable {
    
    // MARK: Properties
    
    /// The main text of the item.
    var text: NSAttributedString { get }
    
    /// The subtext of the item, or `nil` if there is no subtext.
    var subtext: String? { get }
    
    /// The action for the user to take, or `nil` if there is no action.
    var action: String? { get }
    
    /// The comment for this item, or `nil` if there is no comment.
    var comment: String? { get }
    
}

// MARK: - ChecklistCompletableItem

/// Protocol for objects representing "completable" items which may be displayed in a checklist.
protocol ChecklistCompletableItem: ChecklistItem {
    
    /// If set to `true`, this item has been completed.
    var isComplete: MutableProperty<Bool> { get }
    
}
