//
//  DataIndex.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/23/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import CryptoKit
import Foundation

/// Class representing a data index containing application data.
class DataIndex<Object>: Decodable where Object: Decodable {
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified fields.
    init(key: DataIndexKey, version: String, description: String, objects: [Object]) {
        self.key = key
        self.version = version
        self.description = description
        self.objects = objects
    }
    
    // MARK: Properties
    
    /// A unique key for this data index.
    let key: DataIndexKey
    
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
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(key: Self.key(for: decoder),
                  version: try container.decode(String.self, forKey: .version),
                  description: try container.decode(String.self, forKey: .description),
                  objects: try container.decode([Object].self, forKey: .objects))
    }
    
}

extension DataIndex {

    // MARK: Types
    
    /// Enumeration of possible errors when loading a data index.
    enum Error: Swift.Error {
        
        /// The server returned an invalid response.
        case invalidServerResponse
        
        /// The index is corrupted and could not be deserialized.
        case indexCorrupted(error: Swift.Error)
        
        /// An unexpected error occurred.
        case unknownError(error: Swift.Error)
        
        /// A `URLSession` error occurred.
        case URLSessionError(error: Swift.Error)
        
    }
    
    /// Result type returned when attempting to load an index.
    typealias Result = Swift.Result<DataIndex<Object>, Error>
    
    // MARK: Static Methods
    
    /// Asynchronously loads a `DataIndex` from the specified local or remote URL.
    static func load(url: URL, completion: @escaping (Result) -> Void) {
        if url.isFileURL {
            loadAsync(localURL: url, completion: completion)
        } else {
            loadAsync(remoteURL: url, completion: completion)
        }
    }
    
    /// Synchronously loads a `DataIndex` from the specified local URL.
    /// - note: If the load fails for any reason, the app will crash. Therefore this method should only be called for "known good" embedded resources.
    static func loadOrFatalError(localURL url: URL) -> DataIndex<Object> {
        do {
            
            // Synchronously load and return the index
            let index = try loadSync(localURL: url)
            return index
            
        } catch {
            
            // Invalid resource??? This is a programmer error so crash the app
            NSLog("Failed to load data index from \(url)! \(error)")
            fatalError()
            
        }
    }
    
    /// Synchronously loads a `DataIndex` from the specified local `URL`.
    static func loadSync(localURL url: URL) throws -> DataIndex<Object> {
        
        guard url.isFileURL else {
            fatalError("Must be called with a local URL!")
        }
        
        do {
            
            // Load data and decode
            let data = try Data(contentsOf: url)
            return try dataIndex(from: data)
            
        } catch {
            
            // Failed to decode the data
            throw Error.indexCorrupted(error: error)
            
        }
        
    }
    
    /// Returns a unique key for a decoded object in a `DataIndex` instance.
    static func key(for decoder: Decoder) -> DataIndexKey {
        guard let dataIndexKey = decoder.userInfo[.dataIndexKey] as? String else { fatalError() }
        guard !decoder.codingPath.isEmpty else { return dataIndexKey }
        return "\(dataIndexKey)/\(decoder.codingPathString)"
    }
    
    // MARK: Private Static Utility
    
    /// Asynchronously loads a `DataIndex` from the specified local `URL`.
    private static func loadAsync(localURL url: URL, completion: @escaping (Result) -> Void) {
        DispatchQueue.global(qos: .default).async {
            
            /// Returns the specified `Result` to the completion block on the main thread.
            func complete(result: Result) {
                DispatchQueue.main.async { completion(result) }
            }
            
            do {
                
                // Load the index and return
                let index = try loadSync(localURL: url)
                complete(result: .success(index))
                
            } catch let error as Error {
                
                // Some known error occurred
                complete(result: .failure(error))
                
            } catch {
                
                // An unknown error occurred
                complete(result: .failure(.unknownError(error: error)))
                
            }
            
        }
    }
    
    /// Asynchronously loads a `DataIndex` from the specified remote `URL`.
    private static func loadAsync(remoteURL url: URL, completion: @escaping (Result) -> Void) {
        
        // Enforce expected scheme
        guard let scheme = url.scheme, (scheme.lowercased() == "http" || scheme.lowercased() == "https") else {
            fatalError("Must be called with an HTTP or HTTPS URL!")
        }
        
        // Create request
        // NOTE: For data indices, we want to validate our cache in case it's been edited on the server
        let request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData)
        
        // Create task
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            /// Sends the specified `Result` to the completion block on the main queue.
            func complete(result: Result) {
                DispatchQueue.main.async { completion(result) }
            }
            
            // Make sure the error is nil
            if let error = error {
                complete(result: .failure(.URLSessionError(error: error)))
                return
            }
            
            // Make sure the response is valid
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.isStatusCodeOK, let data = data else {
                complete(result: .failure(.invalidServerResponse))
                return
            }
            
            do {
                
                // Parse the data and return if successful
                let index = try dataIndex(from: data)
                complete(result: .success(index))
                
            } catch {
                
                // Bad data
                complete(result: .failure(.indexCorrupted(error: error)))
                
            }
            
        }
        
        // Start task
        task.resume()
        
    }

    /// Decodes a `DataIndex<Object>` from the specified JSON data.
    private static func dataIndex(from data: Data) throws -> DataIndex<Object> {
        
        // Pass the SHA digest to the initialized objects
        let decoder = JSONDecoder()
        decoder.userInfo = [.dataIndexKey: data.sha256DigestString]
        
        // Decode
        return try decoder.decode(DataIndex<Object>.self, from: data)
        
    }
    
}
