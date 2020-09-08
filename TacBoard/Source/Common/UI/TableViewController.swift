//
//  TableViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/7/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// `UITableViewController` subclass with additional tweaks.
class TableViewController: UITableViewController {

    // MARK: UITableViewDelegate
    
    /// Configures the font of each header view when it is displayed.
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        //
        // NOTE
        //
        // This is a workaround for an apparent bug. The font is correctly set by the appearance proxy the *first*
        // time the view is displayed, however, if we refresh the table view with reloadData() it reverts back to
        // the default system fault.
        //
        // To work around this, we manually update the font of the header view here.
        //
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.applicationSystemFont(ofSize: Constants.verySmallTextSize)
        
    }
    
}
