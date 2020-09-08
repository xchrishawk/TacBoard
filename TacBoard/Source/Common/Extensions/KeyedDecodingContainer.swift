//
//  KeyedDecodingContainer.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
    
    /// Decodes a value if it exists, otherwise returns a default.
    func decodeOrDefault<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<Key>.Key, default: T) throws -> T where T : Decodable {
        guard contains(key) else { return `default` }
        return try decode(type, forKey: key)
    }
    
}
