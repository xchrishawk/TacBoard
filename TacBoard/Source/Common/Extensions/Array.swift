//
//  Array.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

extension Array where Element: Decodable {
    
    /// Loads an array from the JSON file at the specified URL.
    static func loadFromJSON(url: URL) throws -> [Element] {
        
        // Load data
        let data = try Data(contentsOf: url)
        
        // Decode and return
        let decoder = JSONDecoder()
        return try decoder.decode([Element].self, from: data)
        
    }
    
}

extension Array where Element: Encodable {
    
    /// Saves this array as a JSON file in the specified URL.
    func saveToJSON(url: URL) throws {
        
        // Encode data
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        
        // Write data to URL
        try data.write(to: url)
        
    }
    
}
