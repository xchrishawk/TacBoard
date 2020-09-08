//
//  HTTPURLResponse.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/23/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    
    // MARK: Types

    /// Struct containing constants for HTTP status codes.
    struct StatusCode {
     
        // MARK: Initialization
        
        private init() { }
        
        // MARK: Constants
        
        /// The HTTP status code is 200 (OK)
        static let ok: Int = 200
        
    }
    
    // MARK: Properties
    
    /// Returns `true` if `statusCode` is equal to `StatusCode.ok`.
    var isStatusCodeOK: Bool {
        return (statusCode == StatusCode.ok)
    }
    
}
