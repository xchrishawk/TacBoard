//
//  SelectableHighlightableTableViewCell.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// `UITableViewCell` with adjustable selection/highlighting behavior.
class SelectableHighlightableTableViewCell: UITableViewCell {

    // MARK: Outlets
    
    /// Array of all primary text labels contained by the cell.
    @IBOutlet private var primaryTextLabels: [UILabel]?
    
    /// Array of all secondary text labels contained by the cell.
    @IBOutlet private var secondaryTextLabels: [UILabel]?
    
    /// Array of all placeholder text labels contained by the cell.
    @IBOutlet private var placeholderTextLabels: [UILabel]?
    
    // MARK: Properties

    /// The background color for the cell when it is highlighted.
    @IBInspectable var highlightedBackgroundColor: UIColor = .clear {
        didSet { updateColors() }
    }
    
    /// The background color for the cell when it is selected.
    @IBInspectable var selectedBackgroundColor: UIColor = .clear {
        didSet { updateColors() }
    }
    
    /// If set to `true`, the color of labels will be inverted when the cell is highlighted.
    @IBInspectable var isTextInvertedWhenHighlighted: Bool = false {
        didSet { updateColors() }
    }
    
    /// If set to `true`, the color of labels will be inverted when the cell is selected.
    @IBInspectable var isTextInvertedWhenSelected: Bool = false {
        didSet { updateColors() }
    }
    
    /// If set to `true`, the cell tint will be inverted when the cell is highlighted.
    @IBInspectable var isTintInvertedWhenHighlighted: Bool = false {
        didSet { updateColors() }
    }
    
    /// If set to `true`, the cell tint will be inverted when the cell is selected.
    @IBInspectable var isTintInvertedWhenSelected: Bool = false {
        didSet { updateColors() }
    }
    
    // MARK: UITableViewCell Overrides
    
    /// Sets up the view after it has been deserialized from the nib.
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Create a selected background view
        selectedBackgroundView = UIView()
        updateColors()
        
    }
    
    /// Sets the `isHighlighted` state of the cell.
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        updateColors(animated: animated)
    }
    
    /// Sets the `isSelected` state of the cell.
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateColors(animated: animated)
    }
    
    // MARK: Private Utility
    
    /// Updates the cell's colors based on the current `isSelected`/`isHighlighted` state.
    private func updateColors(animated: Bool = false) {
        
        /// Updates the text color of a group of labels.
        func update(labels: [UILabel]?, defaultColor: ApplicationColor, invertedColor: ApplicationColor, isInverted: Bool) {
            guard let labels = labels else { return }
            for label in labels {
                label.textColor = (isInverted ? UIColor(application: invertedColor) : UIColor(application: defaultColor))
            }
        }
        
        /// Updates all labels.
        func updateAllLabels(isInverted: Bool) {
            update(labels: primaryTextLabels, defaultColor: .primaryText, invertedColor: .primaryTextInverted, isInverted: isInverted)
            update(labels: secondaryTextLabels, defaultColor: .secondaryText, invertedColor: .secondaryTextInverted, isInverted: isInverted)
            update(labels: placeholderTextLabels, defaultColor: .placeholderText, invertedColor: .placeholderTextInverted, isInverted: isInverted)
        }
        
        // Perform all changes, animating if necessary
        UIView.animate(withDuration: animated ? Constants.defaultAnimationDuration : 0.0) {
        
            // Check what we need to do...
            if self.isSelected {
                
                // Cell is selected
                self.selectedBackgroundView?.backgroundColor = self.selectedBackgroundColor
                updateAllLabels(isInverted: self.isTextInvertedWhenSelected)
                self.tintColor = (self.isTintInvertedWhenSelected ? UIColor(application: .tintInverted) : UIColor(application: .tint))
                
            } else if self.isHighlighted {
                
                // Cell is highlighted but not selected
                self.selectedBackgroundView?.backgroundColor = self.highlightedBackgroundColor
                updateAllLabels(isInverted: self.isTextInvertedWhenHighlighted)
                self.tintColor = (self.isTintInvertedWhenHighlighted ? UIColor(application: .tintInverted) : UIColor(application: .tint))
                
            } else {
                
                // Cell is neither highlighted nor selected
                self.selectedBackgroundView?.backgroundColor = .clear
                updateAllLabels(isInverted: false)
                self.tintColor = UIColor(application: .tint)
                
            }
            
        }
        
    }
    
}
