//
//  AppDelegate.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import UIKit

/// Main application delegate class.
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Fields
    
    private var isFontSetupComplete = false

    // MARK: UIApplicationDelegate

    /// Override point for customization after application launch.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NSLog("Started \(AppInfo.shared.name)...\n- Version: \(AppInfo.shared.version) Build \(AppInfo.shared.build)\n- Build Date: \(AppInfo.shared.date)\n- Git Commit: \(AppInfo.shared.commit)")
        
        // Initialize version manager
        _ = VersionManager.shared
        
        // Initialize global font replacements
        overrideFonts()
        
        return true
        
    }

    /// Called when a new scene session is being created.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    /// Called when the user discards a scene session.
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // no-op
    }
    
    // MARK: Private Utility
    
    /// Overrides the system fonts to the correct customized font.
    private func overrideFonts() {
        
        guard !isFontSetupComplete else { return }
        defer { isFontSetupComplete = true }
        
        // Override system fonts
        UIFont.overrideSystemFonts()

        // Override additional UI components
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).font = UIFont.systemFont(ofSize: Constants.verySmallTextSize)
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont.systemFont(ofSize: Constants.defaultTextSize)] // this is normally bold, but I like it better this way
        UITabBarItem.appearance().setTitleTextAttributes([.font: UIFont.systemFont(ofSize: Constants.verySmallTextSize)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: Constants.verySmallTextSize)], for: .selected) // TODO: doesn't work???
        
    }

}
