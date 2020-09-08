//
//  String.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

extension String {
 
    // MARK: Constants
    
    /// An empty string constant.
    static let empty = String()
    
}

extension Optional where Wrapped == String {

    // MARK: Properties
    
    /// Returns `true` if this `String?` is either `nil` or non-`nil` but empty.
    var isNilOrEmpty: Bool {
        switch self {
        case .some(let string):
            return string.isEmpty
        case .none:
            return true
        }
    }
    
}
