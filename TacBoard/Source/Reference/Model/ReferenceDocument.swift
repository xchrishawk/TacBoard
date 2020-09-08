//
//  ReferenceDocument.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/16/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

// MARK: - ReferenceDataIndex

/// Type representing a data index of reference documents.
typealias ReferenceDataIndex = DataIndex<ReferenceBinder>

extension DataIndex where Object: ReferenceBinder {
    
    // MARK: Class Methods
    
    /// The embedded fallback reference documents index.
    static var fallback: ReferenceDataIndex {
        return ReferenceDataIndex.load(localURL: ContentManager.url(forRelativePath: relativePath, source: .fallback))
    }
    
    /// Asynchronously loads the reference documents index from the specified content manager.
    /// - note: The completion block is guaranteed to be called on the main thread.
    static func load(source: ContentSource, completion: @escaping (ReferenceDataIndex?) -> Void) {
        ReferenceDataIndex.load(url: ContentManager.url(forRelativePath: relativePath, source: source), completion: completion)
    }
    
    // MARK: Private Utility
    
    /// The expected relative path for the reference documents index.
    private static var relativePath: String { return "ReferenceDataIndex.json" }
    
}

// MARK: - ReferenceBinder

/// Type representing a binder of reference documents.
typealias ReferenceBinder = Binder<ReferenceDocument>

// MARK: - ReferenceFolder

/// Type representing a folder of reference documents.
typealias ReferenceFolder = Folder<ReferenceDocument>

// MARK: - ReferenceDocument

/// Class representing a reference document.
class ReferenceDocument: Decodable, ReferenceEquatable {

    // MARK: Initialization
    
    /// Initializes a new instance with the specified values.
    init(title: String, subtitle: String? = nil, type: ReferenceDocumentType, credit: String? = nil, location: ResourceLocation) {
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.credit = credit
        self.location = location
    }
    
    // MARK: Properties
    
    /// The title of the document.
    let title: String
    
    /// The subtitle of the document.
    let subtitle: String?
    
    /// The type of the reference document.
    let type: ReferenceDocumentType
    
    /// The credit string for the document.
    let credit: String?
    
    /// The location where the reference document is located.
    let location: ResourceLocation
    
    // MARK: Decodable
    
    /// `CodingKey` enum for this type.
    private enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case type
        case credit
        case asset
        case path
    }
    
    /// Initializes a new instance with the specified decoder.
    convenience required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let title = try container.decode(String.self, forKey: .title)
        let subtitle = try container.decodeOrDefault(String?.self, forKey: .subtitle, default: nil)
        let type = try container.decode(ReferenceDocumentType.self, forKey: .type)
        let credit = try container.decodeOrDefault(String?.self, forKey: .credit, default: nil)
        
        if let asset = try? container.decode(String.self, forKey: .asset) {
            
            // Image is a local asset
            self.init(title: title,
                      subtitle: subtitle,
                      type: type,
                      credit: credit,
                      location: .asset(name: asset))
            
        } else if let path = try? container.decode(String.self, forKey: .path) {
            
            // Image is a remote file
            self.init(title: title,
                      subtitle: subtitle,
                      type: type,
                      credit: credit,
                      location: .relative(path: path))
            
        } else {
            
            // No location specified
            throw DecodingError.dataCorruptedError(forKey: .asset, in: container, debugDescription: "No document location specified!")
            
        }
        
    }
    
}
