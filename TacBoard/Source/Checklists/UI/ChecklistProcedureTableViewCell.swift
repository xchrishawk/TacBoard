//
//  ChecklistProcedureTableViewCell.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// `UITableViewCell` subclass for selecting a procedure.
class ChecklistProcedureTableViewCell: SelectableHighlightableTableViewCell {

    // MARK: Outlets
    
    /// The label displaying the procedure title.
    @IBOutlet var titleLabel: UILabel?
    
    /// The label displaying the procedure subtitle.
    @IBOutlet var subtitleLabel: UILabel?
    
    /// An image view displaying a check box if the procedure is complete.
    @IBOutlet var isCompleteImageView: UIImageView?
    
}
