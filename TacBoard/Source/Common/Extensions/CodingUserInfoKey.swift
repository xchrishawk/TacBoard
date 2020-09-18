//
//  CodingUserInfoKey.swift
//  TacBoard
//
//  Created by Chris Vig on 9/18/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

extension CodingUserInfoKey {
 
    /// The SHA-2 digest for the data used to generate a data index, represented as a `String`.
    static let dataIndexKey = CodingUserInfoKey(rawValue: "so.invictus.TacBoard.CodingUserInfoKey.dataIndexKey")!
    
}
