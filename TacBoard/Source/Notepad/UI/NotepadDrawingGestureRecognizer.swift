//
//  NotepadDrawingGestureRecognizer.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/2/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

/// Custom `UIGestureRecognizer` subclass for the notepad.
class NotepadDrawingGestureRecognizer: UIGestureRecognizer {

    // MARK: UIGestureRecognizer Overrides

    /// A touch event began.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .began
    }
    
    /// A touch event moved.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .changed
    }
    
    /// A touch event ended.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .ended
    }
    
    /// A touch event was cancelled.
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }
    
}
