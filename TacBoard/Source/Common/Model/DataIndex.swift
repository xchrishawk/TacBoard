//
//  DataIndex.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/23/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Class representing a data index containing application data.
class DataIndex<Object>: Decodable where Object: Decodable {
    
    // MARK: Static Utility
    
    /// Asynchronously loads a `DataIndex` from the specified URL.
    static func load(url: URL, completion: @escaping (DataIndex<Object>?) -> Void) {
        if url.isFileURL {
            
            // Local URL
            let index = load(localURL: url)
            DispatchQueue.main.async { completion(index) }
            
        } else {
         
            // Remote URL
            load(remoteURL: url, completion: completion)
            
        }
    }
    
    /// Synchronously loads a `DataIndex` from the specified local `URL`.
    static func load(localURL url: URL) -> DataIndex<Object> {
        
        assert(url.isFileURL, "Must be called with a local URL!")
        
        do {
            
            // Load data
            let data = try Data(contentsOf: url)
        
            // Decode and return
            let decoder = JSONDecoder()
            return try decoder.decode(DataIndex<Object>.self, from: data)
            
        } catch {
            
            // Failed to load the data from the resource - this is a programming error so crash
            NSLog("Failed to load data from \(url.path)! \(error)")
            fatalInvalidResource()
            
        }
        
    }
    
    /// Asynchronously loads a `DataIndex` from the specified `URL`.
    /// - note: The completion block is guaranteed to be called on the main thread.
    static func load(remoteURL url: URL, completion: @escaping (DataIndex<Object>?) -> Void) {
        
        assert(!url.isFileURL, "Must be called with a remote URL!")
        
        // Create task
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // Validate response
            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.isStatusCodeOK,
                let data = data
                else { return }
            
            // Parse the data
            let decoder = JSONDecoder()
            let index = try? decoder.decode(DataIndex<Object>.self, from: data)
                
            // Successfully downloaded and decoded - call the completion handler on the main thread
            DispatchQueue.main.async {
                completion(index)
            }
            
        }
        
        // Start task
        task.resume()
        
    }

    // MARK: Initialization
    
    /// Initializes a new instance with the specified fields.
    init(version: String, description: String, objects: [Object]) {
        self.version = version
        self.description = description
        self.objects = objects
    }
    
    // MARK: Properties
    
    /// The version number of the data index.
    let version: String
    
    /// A descriptive string for the data index.
    let description: String
    
    /// The list objects contained in the data index.
    let objects: [Object]
 
    // MARK: Decodable
    
    /// `CodingKey` enum for this class.
    private enum CodingKeys: String, CodingKey {
        case version
        case description
        case objects
    }

    /// Initializes a new instance with the specified `Decoder`.
    convenience init(with decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(version: try container.decode(String.self, forKey: .version),
                  description: try container.decode(String.self, forKey: .description),
                  objects: try container.decode([Object].self, forKey: .objects))
    }
    
}
