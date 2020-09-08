//
//  HomeTableViewCell.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/7/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Cell used on the home page.
class HomeTableViewCell: SelectableHighlightableTableViewCell {
    
    // MARK: Outlets

    /// The icon image view.
    @IBOutlet var iconImageView: UIImageView?
    
    /// The title label.
    @IBOutlet var titleLabel: UILabel?
    
    /// The subtitle label.
    @IBOutlet var subtitleLabel: UILabel?
    
    // MARK: UITableViewCell Overrides
    
    /// Initializes the cell when it is deserialized from the nib.
    override func awakeFromNib() {
        super.awakeFromNib()
        initializeCell()
    }
    
    /// Initializes the cell when it is about to be reused.
    override func prepareForReuse() {
        super.prepareForReuse()
        initializeCell()
    }
    
    // MARK: Methods
    
    /// Configures this cell for the specified module.
    func configure<ModuleType>(for module: ModuleType, isEnabled: Bool) where ModuleType: Module {
        
        iconImageView?.image = module.icon
        iconImageView?.safeIsHidden = (module.icon == nil)
        
        titleLabel?.text = (traitCollection.horizontalSizeClass == .compact ? module.compactTitle : module.title)
        titleLabel?.safeIsHidden = false
        
        subtitleLabel?.text = module.author
        subtitleLabel?.safeIsHidden = module.author.isNilOrEmpty
        
        accessoryType = (isEnabled ? .checkmark : .none)
        
    }
    
    // MARK: Private Utility

    /// Sets the cell to its initial state.
    private func initializeCell() {
        
        iconImageView?.image = nil
        iconImageView?.safeIsHidden = true
        
        titleLabel?.text = nil
        titleLabel?.safeIsHidden = true
        
        subtitleLabel?.text = nil
        subtitleLabel?.safeIsHidden = true
        
    }
    
}
