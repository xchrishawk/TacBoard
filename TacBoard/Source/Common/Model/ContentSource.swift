//
//  ContentSource.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/25/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Enumeration of the valid content sources for the application.
enum ContentSource: CustomStringConvertible {
    
    // MARK: Cases
    
    #if DEBUG
    
    /// The application will use the content embedded in the application bundle.
    case local
    
    /// The application will use the content in the CDN staging directory.
    case staging
    
    #endif
    
    /// The application will use the content in the CDN production directory.
    case production
    
    /// The application will use the embedded fallback resources.
    case fallback
    
    // MARK: Properties
    
    /// The default selected content source.
    static let `default`: ContentSource = {
        #if DEBUG
        return .local
        #else
        return .production
        #endif
    }()
    
    /// Returns the base URL for this content source.
    var baseURL: URL {
        switch self {
            
        #if DEBUG
        case .local:
            return Bundle.main.resourceURL!.appendingPathComponent("TacBoardData", isDirectory: true)
        case .staging:
            return URL(string: "http://www.invictus.so/app-content-stage/TacBoardData")!
        #endif
            
        case .production:
            return URL(string: "http://www.invictus.so/app-content/TacBoardData")!
        case .fallback:
            return Bundle.main.resourceURL!
            
        }
    }
    
    /// Returns a custom string for this enum value.
    var description: String {
        switch self {
            
        #if DEBUG
        case .local:
            return "Local"
        case .staging:
            return "Staging"
        #endif
            
        case .production:
            return "Production"
        case .fallback:
            return "Fallback"
            
        }
    }
    
}
