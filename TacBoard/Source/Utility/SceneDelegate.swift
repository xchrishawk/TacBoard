//
//  SceneDelegate.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import ReactiveSwift
import UIKit

/// Main scene delegate class.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: Fields
    
    private var windowDisposableLookup: [UIWindow: Disposable] = [:]

    // MARK: UIWindowSceneDelegate
    
    /// The main window for the scene.
    var window: UIWindow?

    /// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }

        // Set up each window to follow the global display mode setting
        for window in windowScene.windows {
            windowDisposableLookup[window]?.dispose() // sanity check
            windowDisposableLookup[window] = SettingsManager.shared.displayMode.producer.startWithValues { [weak window] displayMode in
                window?.overrideUserInterfaceStyle = displayMode.userInterfaceStyle
            }
        }
        
    }

    /// Called as the scene is being released by the system.
    func sceneDidDisconnect(_ scene: UIScene) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // Stop observing the display mode setting
        for window in windowScene.windows {
            windowDisposableLookup[window]?.dispose()
        }
        
    }

    /// Called when the scene has moved from an inactive state to an active state.
    func sceneDidBecomeActive(_ scene: UIScene) {
        // no-op
    }

    /// Called when the scene will move from an active state to an inactive state.
    func sceneWillResignActive(_ scene: UIScene) {
        // no-op
    }

    /// Called as the scene transitions from the background to the foreground.
    func sceneWillEnterForeground(_ scene: UIScene) {
        // no-op
    }

    /// Called as the scene transitions from the foreground to the background.
    func sceneDidEnterBackground(_ scene: UIScene) {
        // no-op
    }

}
