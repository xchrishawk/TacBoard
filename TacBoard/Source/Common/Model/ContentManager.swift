//
//  ContentManager.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/25/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift

/// Class managing the current content source for the application.
/// - note: This class is not thread safe. All members are expected to be accessed on the main thread.
class ContentManager {
    
    // MARK: Initialization / Singleton
    
    /// The shared `ContentManager` instance.
    static let shared = ContentManager()
    
    /// Initializes a new instance with the specified settings manager.
    private init() {
        self.source = MutableProperty(.default)
    }
    
    // MARK: Properties
    
    /// The currently selected content source for the application.
    let source: MutableProperty<ContentSource>
    
    // MARK: Methods
    
    /// The base URL for the currently selected content source.
    var baseURL: URL {
        return ContentManager.baseURL(source: source.value)
    }
    
    /// Returns the URL for the content at the specified relative path.
    func url(forRelativePath path: String) -> URL {
        return ContentManager.url(forRelativePath: path, source: source.value)
    }
    
    // MARK: Static Utility
    
    /// Returns the base URL for the specified content source.
    static func baseURL(source: ContentSource) -> URL {
        return source.baseURL
    }
    
    /// Returns the URL for the content at the specified relative path with the specified source.
    static func url(forRelativePath path: String, source: ContentSource) -> URL {
        return baseURL(source: source).appendingPathComponent(path)
    }

}
