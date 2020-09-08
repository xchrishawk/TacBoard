//
//  SplitDisplayMode.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/4/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Enumeration of split master view controller display modes.
enum SplitDisplayMode: String, CaseIterable, Defaultable {
    
    // MARK: Cases
    
    /// The master view controller is always shown.
    case show
    
    /// The master view controller is hidden by default. The user can swipe from the side to display it.
    case hide
    
    // MARK: Constants
    
    /// The default split display mode.
    static let `default`: SplitDisplayMode = .show
    
    // MARK: Properties
    
    /// The `UISplitViewController.DisplayMode` enum corresponding to this value.
    var displayMode: UISplitViewController.DisplayMode {
        switch self {
        case .show:
            return .allVisible
        case .hide:
            return .automatic
        }
    }
    
    // MARK: Methods
    
    /// Toggles the value of this enum.
    mutating func toggle() {
        self = {
            switch self {
            case .show:
                return .hide
            case .hide:
                return .show
            }
        }()
    }
    
}
