//
//  Int.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/22/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

extension Int {
    
    /// Returns `true` if this value is negative.
    var isNegative: Bool {
        return self < 0
    }
    
    /// The absolute value of this value.
    var absolute: Int {
        return abs(self)
    }
    
    /// Returns a negative version of this value.
    var negative: Int {
        guard !isNegative else { return self }
        return -self
    }
    
}
