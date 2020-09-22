//
//  VersionManager.swift
//  TacBoard
//
//  Created by Chris Vig on 9/12/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Class responsible for handling version/update information.
class VersionManager {

    // MARK: Types
    
    /// Enumeration of custom upgrade actions for various versions.
    private enum UpgradeAction: String, CaseIterable {
     
        /// Upgrades for version 0.2.0.
        case version0p2p0
        
    }
    
    /// Enumeration of settings maintained by the `VersionManager` class.
    private enum Setting: String {
     
        // MARK: Cases
        
        /// The previously launched major version.
        case previousVersionMajor
        
        /// The previously launched minor version.
        case previousVersionMinor
        
        /// The previously launched revision version.
        case previousVersionRevision
        
        /// If set to `false`, the user has not yet viewed the release notes for this version.
        case userHasViewedReleaseNotesForThisVersion
        
        /// The list of completed upgrade actions.
        case completedUpgradeActions
        
        // MARK: Properties
        
        /// Returns the settings key for this setting.
        var key: String {
            return "so.invictus.TacBoard.VersionManager.\(rawValue)"
        }
        
    }
    
    // MARK: Fields
    
    private let defaults: UserDefaults
    
    // MARK: Initialization / Singleton
    
    /// The shared instance of the `VersionManager` class.
    static let shared = VersionManager()
    
    /// Initializes a new instance with the specified objects.
    private init(defaults: UserDefaults = UserDefaults.standard, appInfo: AppInfo = AppInfo.shared) {
        
        self.defaults = defaults

        // Get previously launched versions
        let previousVersionMajor = defaults.integer(forKey: Setting.previousVersionMajor.key)
        let previousVersionMinor = defaults.integer(forKey: Setting.previousVersionMinor.key)
        let previousVersionRevision = defaults.integer(forKey: Setting.previousVersionRevision.key)
        
        // Get current versions
        let currentVersionMajor = appInfo.versionMajor
        let currentVersionMinor = appInfo.versionMinor
        let currentVersionRevision = appInfo.versionRevision

        // Compare versions...
        if previousVersionMajor == 0 && previousVersionMinor == 0 && previousVersionRevision == 0 {
            
            // This is a new install. Don't pester the user about checking the release notes
            userHasViewedReleaseNotesForThisVersion = true
            
            // Mark all upgrade actions as completed, since we don't need to do any of them
            completedUpgradeActions = Set(UpgradeAction.allCases)
            
        } else if (currentVersionMajor > previousVersionMajor) ||
                  (currentVersionMajor == previousVersionMajor && currentVersionMinor > previousVersionMinor) ||
                  (currentVersionMajor == previousVersionMajor && currentVersionMinor == previousVersionMinor && currentVersionRevision > previousVersionRevision) {
            
            // This is an existing install, but the version has updated. Pester the use to check the release notes
            userHasViewedReleaseNotesForThisVersion = false
            
        }
        
        // Perform any required update actions
        performUpgradeActions()
        
        // Now update the current version
        defaults.set(currentVersionMajor, forKey: Setting.previousVersionMajor.key)
        defaults.set(currentVersionMinor, forKey: Setting.previousVersionMinor.key)
        defaults.set(currentVersionRevision, forKey: Setting.previousVersionRevision.key)
        
    }
    
    // MARK: Properties

    /// If set to `false`, the user has not yet viewed the release notes for this version.
    var userHasViewedReleaseNotesForThisVersion: Bool {
        get { return defaults.bool(forKey: Setting.userHasViewedReleaseNotesForThisVersion.key) }
        set { defaults.set(newValue, forKey: Setting.userHasViewedReleaseNotesForThisVersion.key) }
    }
    
    // MARK: Private Utility
    
    /// Performs the upgrade actions for the specified
    private func performUpgradeActions() {
        
        // Get the current set of upgrade actions which are already complete
        var completedUpgradeActions = self.completedUpgradeActions
        
        // Run through each upgrade action in order, skipping any that are complete
        for upgradeAction in UpgradeAction.allCases {
            if completedUpgradeActions.contains(upgradeAction) { continue }
            switch upgradeAction {
            
            case .version0p2p0:
                // Auto-enable Ka-50 since we added content for it
                guard let ka50 = AircraftModule.for(key: "Ka-50") else { continue }
                SettingsManager.shared.enabledAircraftModules.value.insert(ka50)
            
            }
            completedUpgradeActions.insert(upgradeAction)
        }
        
        // Update the set of completed upgrade actions
        self.completedUpgradeActions = completedUpgradeActions
        
    }
    
    /// The set of completed upgrade actions.
    private var completedUpgradeActions: Set<UpgradeAction> {
        get {
            let array = (defaults.object(forKey: Setting.completedUpgradeActions.key) as? [String]) ?? []
            return Set(array.compactMap { UpgradeAction(rawValue: $0) })
        }
        set {
            let array = newValue.map { $0.rawValue }
            defaults.set(array, forKey: Setting.completedUpgradeActions.key)
        }
    }
    
}
