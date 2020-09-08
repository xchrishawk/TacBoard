//
//  NotepadDrawingView.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/2/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// `UIView` subclass for the `NotepadDrawingViewController` view controller.
class NotepadDrawingView: UIView {

    // MARK: Properties
    
    /// The paths to display.
    var paths: [NotepadPath] = [] {
        didSet { setNeedsDisplay() }
    }
    
    /// Returns a `CGAffineTransform` converting view coordinates to normalized coordinates.
    var transformViewToNormalized: CGAffineTransform {
        return CGAffineTransform(scaleX: (1.0 / bounds.width), y: (1.0 / bounds.height))
    }
    
    /// Returns a `CGAffineTransform` converting normalized coordinates to view coordinates.
    var transformNormalizedToView: CGAffineTransform {
        return CGAffineTransform(scaleX: bounds.width, y: bounds.height)
    }

    // MARK: UIView Overrides
    
    /// Draws the view.
    override func draw(_ rect: CGRect) {
        
        // Get the drawing context
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Clear the drawing area
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(bounds)
        
        // Make sure we have paths to draw
        guard !paths.isEmpty else { return }
        
        context.saveGState()

        // Common configuration
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        // Loop through each path we need to draw
        for path in paths {
            
            // Add the path, converting to view units
            context.saveGState()
            context.concatenate(transformNormalizedToView)
            context.addPath(path.path)
            context.restoreGState()

            // Draw the path
            context.saveGState()
            context.setStrokeColor(path.color.cgColor)
            context.setLineWidth(path.width)
            context.strokePath()
            context.restoreGState()
            
        }
        
        context.restoreGState()
                
    }
    
}
