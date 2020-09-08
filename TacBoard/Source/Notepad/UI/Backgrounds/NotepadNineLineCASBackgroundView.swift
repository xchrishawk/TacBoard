//
//  NotepadNineLineCASBackgroundView.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/2/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// View for drawing the background for the 9-line CAS notepad.
class NotepadNineLineCASBackgroundView: UIView {
    
    // MARK: UIView Overrides
    
    /// Draws the view.
    override func draw(_ rect: CGRect) {

        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Clear the context
        context.clear(bounds)

        // Draw items
        drawGrid(in: context)
        drawLabels(in: context)
        
    }
    
    // MARK: Drawing Commands
    
    /// Draws the cell grid.
    private func drawGrid(in context: CGContext) {
        
        context.saveGState()
        
        // Configure drawing
        context.setStrokeColor(UIColor(application: .notepadForeground).cgColor)
        context.setLineWidth(2.0)
        
        // Add lines for columns
        for column in (0 ..< numberOfColumns - 1) {
            let x = maxX(for: column)
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: height))
        }
        
        // Add lines for rows
        for row in (0 ..< numberOfRows - 1) {
            let y = maxY(for: row)
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: width, y: y))
        }
        
        // Draw the paths
        context.strokePath()
        
        context.restoreGState()
        
    }
    
    /// Draws the label for each cell.
    private func drawLabels(in context: CGContext) {

        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17), .foregroundColor: UIColor(application: .notepadForeground)]
        
        // Loop through each column/row pair
        for column in (0 ..< numberOfColumns) {
            for row in (0 ..< numberOfRows) {
                
                // Get attributed string for label
                guard let label = self.label(column: column, row: row) else { continue }
                let attributedLabel = NSAttributedString(string: label, attributes: attributes)
                
                // Get point to draw at
                let padding: CGFloat = 10.0
                let x = minX(for: column) + padding
                let y = minY(for: row) + padding
                
                // Draw it
                attributedLabel.draw(at: CGPoint(x: x, y: y))
                
            }
        }
        
    }
    
    // MARK: Grid Information
    
    /// The number of columns to draw.
    private let numberOfColumns = 2
    
    /// The number of rows to draw.
    private let numberOfRows = 5

    /// The minimum X value for the specified column.
    private func minX(for column: Int) -> CGFloat {
        return CGFloat(column) * columnSpacing
    }
    
    /// The maximum X value for the specified column.
    private func maxX(for column: Int) -> CGFloat {
        return CGFloat(column + 1) * columnSpacing
    }
    
    /// The minimum Y value for the specified column.
    private func minY(for row: Int) -> CGFloat {
        return CGFloat(row) * rowSpacing
    }
    
    /// The maximum Y value for the specified column.
    private func maxY(for row: Int) -> CGFloat {
        return CGFloat(row + 1) * rowSpacing
    }
    
    /// The row spacing to use.
    private var rowSpacing: CGFloat {
        return (height / CGFloat(numberOfRows))
    }
    
    /// The column spacing to use.
    private var columnSpacing: CGFloat {
        return (width / CGFloat(numberOfColumns))
    }
    
    /// The width of the view.
    private var width: CGFloat {
        return bounds.width
    }
    
    /// The height of the view.
    private var height: CGFloat {
        return bounds.height
    }
    
    /// Returns the label to display for the specified cell.
    private func label(column: Int, row: Int) -> String? {
        
        // On iPhone, we need to use a shorter string since the space is compressed
        let short = UIDevice.current.isPhone
        
        // Depends on column/row...
        switch (column, row) {
        case (0, 0):
            return LocalizableString(short ? .nineLineCASItem1Short : .nineLineCASItem1)
        case (0, 1):
            return LocalizableString(short ? .nineLineCASItem2Short : .nineLineCASItem2)
        case (0, 2):
            return LocalizableString(short ? .nineLineCASItem3Short : .nineLineCASItem3)
        case (0, 3):
            return LocalizableString(short ? .nineLineCASItem4Short : .nineLineCASItem4)
        case (0, 4):
            return LocalizableString(short ? .nineLineCASItem5Short : .nineLineCASItem5)
        case (1, 0):
            return LocalizableString(short ? .nineLineCASItem6Short : .nineLineCASItem6)
        case (1, 1):
            return LocalizableString(short ? .nineLineCASItem7Short : .nineLineCASItem7)
        case (1, 2):
            return LocalizableString(short ? .nineLineCASItem8Short : .nineLineCASItem8)
        case (1, 3):
            return LocalizableString(short ? .nineLineCASItem9Short : .nineLineCASItem9)
        case (1, 4):
            return LocalizableString(short ? .nineLineCASRemarksShort : .nineLineCASRemarks)
        default:
            return nil
        }
        
    }
    
}
