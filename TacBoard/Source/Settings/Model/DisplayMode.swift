//
//  DisplayMode.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/2/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Enumeration of display modes.
enum DisplayMode: String, CaseIterable, CustomStringConvertible, Defaultable {

    // MARK: Cases
    
    /// The application will follow the system light/dark setting.
    case auto
    
    /// The application is locked into light mode.
    case day
    
    /// The application is locked into dark mode.
    case night
    
    // MARK: Constants
    
    /// The default display mode for the application.
    static let `default`: DisplayMode = .auto
    
    // MARK: Properties
    
    /// A string description of this display mode.
    var description: String {
        switch self {
        case .auto:
            return LocalizableString(.displayModeAuto)
        case .day:
            return LocalizableString(.displayModeDay)
        case .night:
            return LocalizableString(.displayModeNight)
        }
    }
    
    /// The `UIUserInterfaceStyle` corresponding to this display mode.
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .auto:
            return .unspecified
        case .day:
            return .light
        case .night:
            return .dark
        }
    }

}
