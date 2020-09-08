//
//  SplitViewControllerDelegate.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/8/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Custom delegate class for split views.
class SplitViewControllerDelegate: NSObject, UISplitViewControllerDelegate {
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified closures.
    init(createDetailNavigationController: @escaping () -> UINavigationController,
         createDetailViewController: @escaping () -> UIViewController,
         createPlaceholderViewController: @escaping () -> PlaceholderViewController,
         isItemSelected: @escaping () -> Bool) {
        
        self.createDetailNavigationController = createDetailNavigationController
        self.createDetailViewController = createDetailViewController
        self.createPlaceholderViewController = createPlaceholderViewController
        self.isItemSelected = isItemSelected
        
        super.init()
        
    }
    
    // MARK: Properties
    
    /// Creates a detail navigation controller.
    let createDetailNavigationController: () -> UINavigationController
    
    /// Creates a detail view controller for the currently selected item.
    let createDetailViewController: () -> UIViewController
    
    /// Creates a placeholder view controller.
    let createPlaceholderViewController: () -> PlaceholderViewController
    
    /// Returns `true` if there is currently a selected item.
    let isItemSelected: () -> Bool
    
    // MARK: UISplitViewControllerDelegate
    
    /// Displays a detail view controller in the embedded split view controller.
    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        
        // Action depends on whether or not we're collapsed...
        if splitViewController.isCollapsed {
            
            // Get the main navigation controller
            guard
                let mainNavigationController = splitViewController.viewControllers.first as? UINavigationController
                else { return false /* ??? */ }
            
            if let detailNavigationController = mainNavigationController.topViewController as? UINavigationController {
                if vc is PlaceholderViewController {
                    
                    // There is a detail nav controller on the stack, and we are attempting to push a placeholder.
                    // We don't want to display placeholders in collapsed mode, so instead, pop the detail navigation
                    // controller off of the main stack.
                    mainNavigationController.popViewController(animated: true)
                    return true
                    
                } else {
                    
                    // There is already a detail navigation controller on the stack - replace its page stack
                    detailNavigationController.viewControllers = [vc]
                    return true
                    
                }
            } else {
                if vc is PlaceholderViewController {
                    
                    // No detail nav controller on the stack, and we are attempting to push a placeholder.
                    // We don't want to display placeholders in collapsed mode, so just do nothing.
                    return true
                    
                } else {
                    
                    // No detail controller yet - we need to push one onto the stack
                    let detailNavigationController = createDetailNavigationController()
                    detailNavigationController.viewControllers = [vc]
                    mainNavigationController.pushViewController(detailNavigationController, animated: true)
                    return true
                    
                }
            }
            
        } else {
            
            // We are *not* in collapsed mode. Try to get the detail nav controller, if it exists.
            if splitViewController.viewControllers.count > 1, let detailNavigationController = splitViewController.viewControllers.last as? UINavigationController {
                
                // Found a detail nav controller. All we have to do is replace the existing nav stack
                detailNavigationController.viewControllers = [vc]
                return true
                
            } else {
                
                // No detail navigation controller present. Create one and add it to the split view controller
                let detailNavigationController = createDetailNavigationController()
                detailNavigationController.viewControllers = [vc]
                splitViewController.viewControllers.append(detailNavigationController)
                return true
                
            }
            
        }
        
    }
    
    /// Handles collapsing view controllers when switching into collapsed mode.
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        // If the secondary view controller is a placeholder view controller, then return true.
        // This will prevent the split view controller from merging the detail view controller
        // onto the master page stack, so we won't see the "placeholder" view on top of the stack
        if let detailNavigationController = secondaryViewController as? UINavigationController, detailNavigationController.topViewController is PlaceholderViewController {
            return true
        }
        
        // Otherwise, let the split view controller behave normally
        return false
        
    }
    
    /// Separates the secondary view from the specified primary view.
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        
        if isItemSelected() {
            
            // There is a selected item
            if let mainNavigationController = primaryViewController as? UINavigationController,
                let detailNavigationController = mainNavigationController.topViewController as? UINavigationController,
                !(detailNavigationController.topViewController is PlaceholderViewController) {
                
                // Existing page stack on top of the main navigation controller is valid
                return detailNavigationController
                
            } else {
                
                // We have a selected item, but the existing page stack is invalid. Create a new one
                let detailNavigationController = createDetailNavigationController()
                let detailController = createDetailViewController()
                detailNavigationController.viewControllers = [detailController]
                return detailNavigationController
                
            }
            
        } else {
            
            // There is no selected item
            if let mainNavigationController = primaryViewController as? UINavigationController,
                let detailNavigationController = mainNavigationController.topViewController as? UINavigationController,
                detailNavigationController.topViewController is PlaceholderViewController {
                
                // Existing page stack on top of the main navigation controller is valid
                return detailNavigationController
                
            } else {
                
                // No selected item, and no valid existing page stack. Create a new one.
                let detailNavigationController = createDetailNavigationController()
                let placeholderController = createPlaceholderViewController()
                detailNavigationController.viewControllers = [placeholderController]
                return detailNavigationController
                
            }
            
        }
        
    }
    
}
