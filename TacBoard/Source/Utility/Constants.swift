//
//  Constants.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Struct for namespacing constants.
struct Constants {

    // MARK: Initialization
    
    /// Struct is not instantiable.
    private init() { }
    
    // MARK: Constants
    
    /// The default duration for animations.
    static let defaultAnimationDuration: TimeInterval = (1.0 / 3.0)
    
    /// The default brightness to use for media in dark mode.
    static let defaultDarkModeBrightness: CGFloat = 0.9
    
    /// The default row height.
    static let defaultRowHeight: CGFloat = 60.0
    
    /// The URL for the document directory.
    static let documentDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    
    /// A zero-length duration to disable animations.
    static let noAnimationDuration: TimeInterval = 0.0
    
    /// The border width to use for popovers.
    static let popoverBorderWidth: CGFloat = 2.0
    
    /// The corner radius to use for popovers.
    static let popoverCornerRadius: CGFloat = 13.0
    
    /// The default text size.
    static let defaultTextSize: CGFloat = 17.0
    
    /// The large text size.
    static let largeTextSize: CGFloat = 21.0
    
    /// The small text size.
    static let smallTextSize: CGFloat = 14.0
    
    /// The very small text size.
    static let verySmallTextSize: CGFloat = 12.0
    
}
