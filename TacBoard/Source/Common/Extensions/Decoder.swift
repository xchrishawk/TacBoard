//
//  Decoder.swift
//  TacBoard
//
//  Created by Chris Vig on 9/18/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

extension Decoder {
 
    /// Returns a `String` representation of the `CodingPath` property.
    var codingPathString: String {
        return codingPath.compactMap { $0.stringValue }.joined(separator: "/")
    }
    
}
