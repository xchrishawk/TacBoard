//
//  Assets.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

// MARK: - ApplicationColor

/// Enumeration of colors defined in the application assets.
enum ApplicationColor: String {

    // MARK: Cases
    
    /// The default background color.
    case background = "BackgroundColor"
    
    /// The background color for highlighted cells.
    case highlightedCellBackground = "HighlightedCellBackgroundColor"
    
    /// The placeholder text color.
    case placeholderText = "PlaceholderTextColor"
    
    /// The inverted placeholder text color.
    case placeholderTextInverted = "PlaceholderTextInvertedColor"
    
    /// The popover border color.
    case popoverBorder = "PopoverBorderColor"
    
    /// The primary text color.
    case primaryText = "PrimaryTextColor"
    
    /// The inverted primary text color.
    case primaryTextInverted = "PrimaryTextInvertedColor"
    
    /// The background color for the notepad.
    case notepadBackground = "NotepadBackgroundColor"
    
    /// The black/white notepad color.
    case notepadBlackWhite = "NotepadBlackWhiteColor"
    
    /// The blue notepad color.
    case notepadBlue = "NotepadBlueColor"
    
    /// The foreground color for the notepad.
    case notepadForeground = "NotepadForegroundColor"
    
    /// The green notepad color.
    case notepadGreen = "NotepadGreenColor"
    
    /// The indigo notepad color.
    case notepadIndigo = "NotepadIndigoColor"
    
    /// The orange notepad color.
    case notepadOrange = "NotepadOrangeColor"
    
    /// The red notepad color.
    case notepadRed = "NotepadRedColor"
    
    /// The violet notepad color.
    case notepadViolet = "NotepadVioletColor"
    
    /// The yellow notepad color.
    case notepadYellow = "NotepadYellowColor"
    
    /// The secondary background color.
    case secondaryBackground = "SecondaryBackgroundColor"
    
    /// The secondary text color.
    case secondaryText = "SecondaryTextColor"
    
    /// The inverted secondary text color.
    case secondaryTextInverted = "SecondaryTextInvertedColor"
    
    /// The background color for selected cells.
    case selectedCellBackground = "SelectedCellBackgroundColor"
    
    /// The application tint color.
    case tint = "TintColor"
    
    /// The inverted application tint color.
    case tintInverted = "TintInvertedColor"
    
}
