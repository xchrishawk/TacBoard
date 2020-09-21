//
//  MainViewController.swift
//  TacBoard
//
//  Created by Chris Vig on 9/21/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// The main view controller for the application.
class MainViewController: UIViewController {
    
    // MARK: Fields
    
    private var embeddedTabBarController: UITabBarController?
    
    // MARK: UIViewController Overrides
    
    /// Prepares for the specified segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {

        case "EmbedTabBarController":
            guard let controller = segue.destination as? UITabBarController else { fatalInvalidSegue() }
            embeddedTabBarController = controller
            
        default:
            break
        
        }
    }
    
    /// Displays the help page with the specified initial anchor.
    func showHelp(initialAnchor: String? = nil) {
        
        let helpViewController: HomeHelpViewController = UIStoryboard.App.home.instantiateViewController(identifier: "Help")
        helpViewController.initialAnchor = initialAnchor
        
        showHomePageStack([helpViewController])
        
    }
    
    /// Displays the user content list.
    func showUserContentList() {
        
        let aboutViewController: HomeAboutViewController = UIStoryboard.App.home.instantiateViewController(identifier: "About")
        let userContentListViewController: UserContentListViewController = UIStoryboard.App.home.instantiateViewController(identifier: "UserContentList")
        
        showHomePageStack([aboutViewController, userContentListViewController])

    }
    
    // MARK: Properties
    
    /// The root `MainViewController` for the application, if one is active.
    static var active: MainViewController? {
        
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first,
            let controller = window.rootViewController as? MainViewController
            else { return nil }

        return controller
        
    }
    
    // MARK: Private Utility
    
    /// Displays the specified page stack from the home page.
    private func showHomePageStack(_ controllers: [UIViewController]) {
        
        guard
            let embeddedTabBarController = embeddedTabBarController,
            let embeddedViewControllers = embeddedTabBarController.viewControllers,
            let homeIndex = embeddedViewControllers.firstIndex(where: { ($0 as? UINavigationController)?.viewControllers.first is HomeViewController }),
            let homeNavigationController = embeddedViewControllers[homeIndex] as? UINavigationController,
            let homeViewController = homeNavigationController.viewControllers.first as? HomeViewController
            else { return }
        
        homeNavigationController.setViewControllers([homeViewController] + controllers, animated: false)
        embeddedTabBarController.selectedIndex = homeIndex
        
    }
    
}
