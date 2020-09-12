//
//  SegmentedControl.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/2/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Custom segmented control with additional functionality.
class SegmentedControl: UISegmentedControl {
    
    // MARK: Properties

    /// The text color to use for the title of non-selected segments.
    @IBInspectable var normalTitleTextColor: UIColor = .label {
        didSet { updateTitleTextAttributes() }
    }
    
    /// The text color to use for the title of selected segments.
    @IBInspectable var selectedTitleTextColor: UIColor = .label {
        didSet { updateTitleTextAttributes() }
    }
    
    // MARK: UIView Overrides
    
    /// Sets up the view after it is deserialized from the nib.
    override func awakeFromNib() {
        super.awakeFromNib()
        updateTitleTextAttributes()
    }
    
    // MARK: Methods
    
    /// Configures this segmented controller to display a segment for each item in the specified enum type.
    func configure<T: CaseIterable & CustomStringConvertible>(for _: T.Type, animated: Bool = false) {
        
        // Remove any existing segments
        removeAllSegments()
        
        // Add a segment for each item in the enum
        for (index, item) in T.allCases.enumerated() {
            insertSegment(withTitle: String(describing: item), at: index, animated: animated)
        }
        
    }
    
    /// Returns a value of the specified enum type for the currently selected index.
    func value<T: CaseIterable>(for _: T.Type) -> T where T.AllCases.Index == Int {
        
        // Note that this will crash if the selected segment index is not valid for the specified enum.
        // This is what we want in this case since it represents a programmer error.
        return T.allCases[selectedSegmentIndex]
        
    }
    
    /// Sets the selected segment index for the specified enum type.
    func setValue<T: CaseIterable & Equatable>(_ value: T, for _: T.Type) where T.AllCases.Index == Int {
        guard let index = T.allCases.firstIndex(where: { $0 == value }) else { fatalError("Value not found!") }
        selectedSegmentIndex = index
    }
    
    // MARK: Private Utility
    
    /// Updates the title text attributes.
    private func updateTitleTextAttributes() {
     
        // I would prefer to not set the font here, but if we use the UIAppearance proxy then it overrides the text colors
        setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14.0), .foregroundColor: normalTitleTextColor], for: .normal)
        setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14.0), .foregroundColor: selectedTitleTextColor], for: .selected)
        
    }

}
