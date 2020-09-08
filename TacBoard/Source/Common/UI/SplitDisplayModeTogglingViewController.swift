//
//  SplitDisplayModeTogglingViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/17/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for view controllers with a split mode toggle button.
protocol SplitDisplayModeTogglingViewController {
    
    /// The `UIBarButtonItem` for toggling the split display mode.
    var splitDisplayModeBarButtonItem: UIBarButtonItem? { get }

}

extension SplitDisplayModeTogglingViewController where Self: UIViewController {

    /// Updates the visibility of `splitDisplayModeBarButtonItem` based on the specified trait collection, using the specified transition coordinator.
    /// - note: If `traitCollection` is `nil`, the view controller's current trait collection will be checked.
    func updateIsSplitDisplayModeButtonHidden(with traitCollection: UITraitCollection? = nil, coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            self.updateIsSplitDisplayModeButtonHidden(with: traitCollection)
        }, completion: nil)
    }
    
    /// Updates the visibility of `splitDisplayModeBarButtonItem` based on the specified trait collection.
    /// - note: If `traitCollection` is `nil`, the view controller's current trait collection will be checked.
    func updateIsSplitDisplayModeButtonHidden(with traitCollection: UITraitCollection? = nil) {
     
        let traitCollection = traitCollection ?? self.traitCollection
        
        // Always hide the button in compact horizontal size class
        guard traitCollection.horizontalSizeClass != .compact else {
            isSplitDisplayModeBarButtonItemHidden = true
            return
        }
        
        // If this is iPhone in regular horizontal size class (i.e., a Pro model in landscape mode), show the button
        guard !UIDevice.current.isPhone else {
            isSplitDisplayModeBarButtonItemHidden = false
            return
        }
        
        // Otherwise, this is an iPad. Hide the button in landscape mode
        isSplitDisplayModeBarButtonItemHidden = UIApplication.shared.isLandscape
        
    }
    
    /// Shows or hides the `splitDisplayModeBarButtonItem` bar button item.
    var isSplitDisplayModeBarButtonItemHidden: Bool {
        get {
            
            guard
                let splitDisplayModeBarButtonItem = splitDisplayModeBarButtonItem
                else { return false }
            
            return !(navigationItem.rightBarButtonItems?.contains { $0 === splitDisplayModeBarButtonItem } ?? false)
            
        }
        set {
         
            guard
                let splitDisplayModeBarButtonItem = splitDisplayModeBarButtonItem,
                newValue != isSplitDisplayModeBarButtonItemHidden
                else { return }
            
            if newValue {
                navigationItem.rightBarButtonItems?.removeAll { $0 === splitDisplayModeBarButtonItem }
            } else {
                navigationItem.rightBarButtonItems?.append(splitDisplayModeBarButtonItem)
            }
            
        }
    }
    
}
