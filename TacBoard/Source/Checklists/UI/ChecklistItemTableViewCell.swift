//
//  ChecklistItemTableViewCell.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// `UITableViewCell` subclass displaying an individual item in a checklist procedure.
class ChecklistItemTableViewCell: SelectableHighlightableTableViewCell {

    // MARK: Outlets
    
    /// The label for the text of the item.
    @IBOutlet var itemTextLabel: UILabel?
    
    /// The label for the subtext of the item.
    @IBOutlet var itemSubtextLabel: UILabel?
    
    /// The label for the action of the item.
    @IBOutlet var itemActionLabel: UILabel?
    
    /// The label for the comment of the item.
    @IBOutlet var itemCommentLabel: UILabel?
    
    /// An image view displaying a green check if the item is completed.
    @IBOutlet var isCompleteImageView: UIImageView?
    
    /// An image view displaying a greyed out check if the item is not completed.
    @IBOutlet var isNotCompleteImageView: UIImageView?
    
    /// Label showing the N/A text for non-completable items.
    @IBOutlet var isNotApplicableLabel: UILabel?
    
    /// The container view for the comment.
    /// - note: I attempted to use a stack view to embed the comment view, however this led to unresolvable
    ///   autolayout warnings in the console log when initially displaying the cell.
    @IBOutlet var itemCommentView: UIView?
    
    /// The constraint to display or hide the comment view.
    @IBOutlet var itemCommentViewConstraint: NSLayoutConstraint?

}
