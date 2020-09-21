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
        
        // Open URLs if there are any specified
        if !connectionOptions.urlContexts.isEmpty {
            self.scene(scene, openURLContexts: connectionOptions.urlContexts)
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
    
    /// Called when the application should open a URL.
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            UserContentManager.shared.importFile(at: context.url) { [weak self] error in

                // Alert contents depend on whether the operation succeeded
                let alert: UIAlertController = {
                    if let error = error as? UserContentError, case .invalidFile = error {
                        
                        // The file was imported successfully, but was invalid
                        return UIAlertController(title: LocalizableString(.userContentImportInvalidTitle),
                                                 message: LocalizableString(.userContentImportInvalidMessage),
                                                 preferredStyle: .alert)
                        
                    } else if error != nil {
                        
                        // The file could not be copied to the user content directory
                        return UIAlertController(title: LocalizableString(.userContentImportFailedTitle),
                                                 message: LocalizableString(.userContentImportFailedMessage),
                                                 preferredStyle: .alert)
                        
                    } else {
                        
                        // The import succeeded
                        return UIAlertController(title: LocalizableString(.userContentImportSucceededTitle),
                                                 message: LocalizableString(.userContentImportSucceededMessage),
                                                 preferredStyle: .alert)
                        
                    }
                }()
                
                // Present the alert
                alert.addAction(UIAlertAction(title: LocalizableString(.genericOK), style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: LocalizableString(.userContentListShowUserContentList), style: .default) { _ in MainViewController.active?.showUserContentList() })
                self?.frontMostViewController?.present(alert, animated: true, completion: nil)

            }
        }
    }
    
    // MARK: Private Utility
    
    /// Returns the "frontmost" view controller which is not presenting another view controller.
    private var frontMostViewController: UIViewController? {
        var controller = window?.rootViewController
        while controller?.presentedViewController != nil {
            controller = controller?.presentedViewController
        }
        return controller
    }

}
