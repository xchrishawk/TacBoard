//
//  Module.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/7/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Module

/// Typealias for objects subclassing `ModuleBase` and implementing `ModuleProtocol`.
typealias Module = ModuleBase & ModuleProtocol

// MARK: - ModuleProtocol

/// Protocol with additional fields for modules.
protocol ModuleProtocol {
 
    // MARK: Constants
    
    /// Returns an array of all available modules of this type.
    static var all: [Self] { get }
    
    // MARK: Properties
    
    /// Returns a `UIImage` representing the icon for this module.
    var icon: UIImage? { get }
    
}

extension ModuleProtocol where Self: ModuleBase {
    
    /// Returns the module with the specified `key`.
    static func `for`(key: String) -> Self? {
        return all.first { $0.key == key }
    }
 
    /// Returns an array of all modules with the `isDefaultEnabled` flag set.
    static var defaultEnabledModules: [Self] {
        return all.filter { $0.isDefaultEnabled }
    }
    
    /// Returns an array of all modules with the `isPrimary` flag set.
    static var primaryModules: [Self] {
        return all.filter { $0.isPrimary }
    }
    
}

// MARK: - ModuleBase

/// Base class for objects representing enableable simulator modules.
class ModuleBase: Decodable, Hashable {
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified values.
    init(key: String,
         title: String,
         compactTitle: String? = nil,
         author: String?,
         isDefaultEnabled: Bool,
         isPrimary: Bool) {
     
        self.key = key
        self.title = title
        self.compactTitle = compactTitle ?? title
        self.author = author
        self.isDefaultEnabled = isDefaultEnabled
        self.isPrimary = isPrimary
        
    }
    
    // MARK: Properties
    
    /// The key string for the module.
    let key: String
    
    /// The localized display title of the module.
    let title: String
    
    /// A compact version of the `title` property.
    let compactTitle: String
    
    /// The localized display author of the module, if any.
    let author: String?
    
    /// Returns `true` if this module should be enabled by default.
    let isDefaultEnabled: Bool
    
    /// Returns `true` if this is a primary module.
    let isPrimary: Bool
    
    // MARK: Codable
    
    /// `CodingKey` enum for this class.
    private enum CodingKeys: String, CodingKey {
        case key
        case title
        case compactTitle
        case author
        case isDefaultEnabled
        case isPrimary
    }
    
    /// Initializes a new instance with the specified decoder.
    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(key: try container.decode(String.self, forKey: .key),
                  title: try container.decode(String.self, forKey: .title),
                  compactTitle: try container.decodeOrDefault(String?.self, forKey: .compactTitle, default: nil),
                  author: try container.decode(String?.self, forKey: .author),
                  isDefaultEnabled: try container.decode(Bool.self, forKey: .isDefaultEnabled),
                  isPrimary: try container.decode(Bool.self, forKey: .isPrimary))
    }
    
    // MARK: Equatable
    
    /// Equality function.
    static func ==(lhs: ModuleBase, rhs: ModuleBase) -> Bool {
        return (type(of: lhs) == type(of: rhs) && lhs.key == rhs.key)
    }
    
    // MARK: Hashable
    
    /// Hashes this object into the specified hasher.
    func hash(into hasher: inout Hasher) {
        key.hash(into: &hasher)
    }
    
}
