//
//  Data.swift
//  TacBoard
//
//  Created by Chris Vig on 9/18/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import CryptoKit
import Foundation

extension Data {

    /// Returns a SHA256 digest string for this data object.
    var sha256DigestString: String {
        return SHA256.hash(data: self).compactMap { String(format: "%02x", $0) }.joined()
    }
    
}
