//
//  FolderTableViewCell.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/15/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Cell for displaying folders.
class FolderTableViewCell: SelectableHighlightableTableViewCell {

    // MARK: Outlets
    
    /// The label for the title of the folder.
    @IBOutlet private var titleLabel: UILabel?
    
    // MARK: Methods
    
    /// Configures this cell for the specified folder.
    func configure<Item>(for folder: Folder<Item>) {
        titleLabel?.text = folder.title
    }
    
}
