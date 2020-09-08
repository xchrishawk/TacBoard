//
//  NotepadPath.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/2/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Struct containing a single path drawn by the user.
struct NotepadPath {
    
    // MARK: Constants
    
    /// The default path color.
    static var defaultColor: UIColor {
        return UIColor(application: .tint)
    }
    
    /// The minimum path width.
    static var minimumWidth: CGFloat {
        return (UIDevice.current.isPhone ? 3.0 : 5.0)
    }
    
    /// The maximum path width.
    static var maximumWidth: CGFloat {
        return (UIDevice.current.isPhone ? 36.0 : 60.0)
    }
    
    /// The default path width.
    static var defaultWidth: CGFloat {
        return (UIDevice.current.isPhone ? 6.0 : 10.0)
    }
    
    // MARK: Fields
    
    private let mutablePath: CGMutablePath
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified values.
    init(at point: CGPoint? = nil, color: UIColor = NotepadPath.defaultColor, width: CGFloat = NotepadPath.defaultWidth) {
        self.mutablePath = CGMutablePath()
        if let point = point { self.mutablePath.move(to: point) }
        self.color = color
        self.width = width
    }
    
    // MARK: Properties
    
    /// The path to draw.
    var path: CGPath { mutablePath.copy()! }
    
    /// The color of the path.
    let color: UIColor
    
    /// The width of the path.
    let width: CGFloat

    // MARK: Methods

    /// Moves the path to the specified point.
    mutating func move(to point: CGPoint) {
        mutablePath.move(to: point)
    }
    
    /// Adds a line to the specified point.
    mutating func addLine(to point: CGPoint) {
        mutablePath.addLine(to: point)
    }
    
}
