//
//  ReferenceDocumentTableViewCell.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/16/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Class for `UITableViewCell`s displaying reference documents.
class ReferenceDocumentTableViewCell: SelectableHighlightableTableViewCell {

    // MARK: Outlets
    
    /// The label for the document title.
    @IBOutlet var titleLabel: UILabel?
    
    /// The label for the document subtitle.
    @IBOutlet var subtitleLabel: UILabel?
    
}
