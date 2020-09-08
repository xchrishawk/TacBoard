//
//  AirportDetailTableViewCell.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/6/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// `UITableViewCell` subclass for displaying airport details.
class AirportDetailTableViewCell: SelectableHighlightableTableViewCell {

    // MARK: Outlets
    
    /// The label for the title of the data contained in the cell.
    @IBOutlet var titleLabel: UILabel?
    
    /// The auxiliary data stack view, located immediately to the right of the title label.
    @IBOutlet var auxiliaryDataView: UIStackView?
    
    /// The first auxiliary data label.
    @IBOutlet var auxiliaryData1Label: UILabel?
    
    /// The second auxiliary data label.
    @IBOutlet var auxiliaryData2Label: UILabel?
    
    /// The first (i.e., top) data label.
    @IBOutlet var data1Label: UILabel?
    
    /// The second (i.e., bottom) data label.
    @IBOutlet var data2Label: UILabel?
    
    /// The placeholder text label.
    @IBOutlet var placeholderLabel: UILabel?
    
    /// The accessory button label.
    @IBOutlet var accessoryButton: UIButton?
    
    // MARK: UITableViewCell Overrides
    
    /// Initializes the cell after it is deserialized from the nib.
    override func awakeFromNib() {
        super.awakeFromNib()
        initializeCell()
    }
    
    /// Initializes the cell when it is about to be reused.
    override func prepareForReuse() {
        super.prepareForReuse()
        initializeCell()
    }
    
    // MARK: Private Utility
    
    /// Initializes the state of the cell.
    private func initializeCell() {
        
        accessoryType = .none
        selectionStyle = .none
        
        titleLabel?.text = nil
        titleLabel?.safeIsHidden = true
        
        auxiliaryDataView?.safeIsHidden = true
        
        auxiliaryData1Label?.text = nil
        auxiliaryData1Label?.safeIsHidden = true
        
        auxiliaryData2Label?.text = nil
        auxiliaryData2Label?.safeIsHidden = false
        
        data1Label?.text = nil
        data1Label?.safeIsHidden = true
        
        data2Label?.text = nil
        data2Label?.safeIsHidden = true
        
        placeholderLabel?.text = nil
        placeholderLabel?.safeIsHidden = true
        
        accessoryButton?.setImage(nil, for: .normal)
        accessoryButton?.safeIsHidden = true
        
    }
    
}
