//
//  HomeTitleTableViewCell.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/9/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Custom cell for the app title on the home page.
class HomeTitleTableViewCell: SelectableHighlightableTableViewCell {

    // MARK: Outlets
    
    /// The label for the application title.
    @IBOutlet var titleLabel: UILabel?
    
    /// The label for the application version.
    @IBOutlet var versionLabel: UILabel?
    
}
