//
//  UIColor.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/2/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    // MARK: Initialization
    
    /// Initializes with the specified color from the application assets.
    convenience init(application: ApplicationColor) {
        self.init(named: application.rawValue)!
    }
    
    // MARK: Methods
    
    /// Returns `true` if this color is equal to the specified color by directly comparing RGBA values.
    func isEqualToColor(_ color: UIColor) -> Bool {
        
        let (r1, g1, b1, a1) = components
        let (r2, g2, b2, a2) = color.components
        
        /// Compares `CGFloat`s for equality within a small epsilon.
        func almostEqual(_ x: CGFloat, _ y: CGFloat) -> Bool {
            let epsilon: CGFloat = 0.00000001
            return (abs(x - y) < epsilon)
        }
        
        return (almostEqual(r1, r2) && almostEqual(g1, g2) && almostEqual(b1, b2) && almostEqual(a1, a2))
        
    }
    
    /// Returns the RGBA components of this color.
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return (r, g, b, a)
        
    }
    
}
