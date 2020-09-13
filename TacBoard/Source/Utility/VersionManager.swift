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
            
        } else if (currentVersionMajor > previousVersionMajor) ||
                  (currentVersionMajor == previousVersionMajor && currentVersionMinor > previousVersionMinor) ||
                  (currentVersionMajor == previousVersionMajor && currentVersionMinor == previousVersionMinor && currentVersionRevision > previousVersionRevision) {
            
            // This is an existing install, but the version has updated. Pester the use to check the release notes
            userHasViewedReleaseNotesForThisVersion = false
            
        }
        
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
    
}
