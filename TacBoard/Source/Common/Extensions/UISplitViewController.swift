//
//  UISplitViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/15/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift
import UIKit

extension UISplitViewController {

    /// - note: This should only be called once for the life of the view controller!
    func observeSplitDisplayModeProperty(_ property: MutableProperty<SplitDisplayMode>) {
        
        // Don't animate the first time
        var animated = false
        
        // Update any time the property changes
        property.producer.take(duringLifetimeOf: self).startWithValues { [unowned self] splitDisplayMode in
            self.updateDisplayMode(to: splitDisplayMode, animated: animated)
            animated = true
        }
        
    }
    
    // MARK: Private Utility
    
    /// Updates the visibility of the master view controller.
    private func updateDisplayMode(to splitDisplayMode: SplitDisplayMode, animated: Bool) {
        
        // Make sure something actually changed
        let displayMode = splitDisplayMode.displayMode
        guard displayMode != preferredDisplayMode else { return }
        
        // Animate (or not)
        // NOTE: If we are setting this to .automatic, then we need to set to .primaryHidden first to force close the master view controller
        UIView.animate(withDuration: animated ? Constants.defaultAnimationDuration : Constants.noAnimationDuration, animations: {
            self.preferredDisplayMode = (displayMode == .automatic ? .primaryHidden : displayMode)
        }, completion: { _ in
            guard displayMode == .automatic else { return }
            self.preferredDisplayMode = .automatic
        })
        
    }
    
}
