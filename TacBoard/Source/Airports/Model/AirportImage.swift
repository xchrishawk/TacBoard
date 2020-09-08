//
//  AirportImage.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/6/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Class representing an airport image.
class AirportImage: Decodable {

    // MARK: Initialization
    
    /// Initializes a new instance with the specified values.
    init(title: String, compactTitle: String? = nil, credit: String? = nil, location: ResourceLocation) {
        self.title = title
        self.compactTitle = compactTitle ?? title
        self.credit = credit
        self.location = location
    }
    
    // MARK: Properties
    
    /// The title of the image.
    let title: String
    
    /// The title of the image, shortened for compact layouts.
    let compactTitle: String
    
    /// The image credit, or `nil` if there is no credit.
    let credit: String?
    
    /// The location of the image file.
    let location: ResourceLocation
    
    // MARK: Codable
    
    /// The `CodingKey` enum for this class.
    private enum CodingKeys: String, CodingKey {
        case title
        case compactTitle
        case credit
        case asset
        case path
    }
    
    /// Initializes a new instance with the specified `Decoder`.
    convenience required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let title = try container.decode(String.self, forKey: .title)
        let compactTitle = try container.decodeOrDefault(String?.self, forKey: .compactTitle, default: nil)
        let credit = try container.decodeOrDefault(String?.self, forKey: .credit, default: nil)
        
        if let asset = try? container.decode(String.self, forKey: .asset) {
            
            // Image is a local asset
            self.init(title: title,
                      compactTitle: compactTitle,
                      credit: credit,
                      location: .asset(name: asset))
            
        } else if let path = try? container.decode(String.self, forKey: .path) {
         
            // Image is a path relative to the base content URL
            self.init(title: title,
                      compactTitle: compactTitle,
                      credit: credit,
                      location: .relative(path: path))
            
        } else {
         
            // No location specified
            throw DecodingError.dataCorruptedError(forKey: .asset, in: container, debugDescription: "No image location specified!")
            
        }
        
    }
    
}
