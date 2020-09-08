//
//  Double.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/22/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

extension Double {
    
    /// Returns `true` if this value is negative.
    var isNegative: Bool {
        return (self < 0.0)
    }
    
    /// The absolute value of this value.
    var absolute: Double {
        return abs(self)
    }
    
    /// Returns a negative version of this value.
    var negative: Double {
        guard !isNegative else { return self }
        return -self
    }
    
    /// Returns the fractional part of this value.
    var fractionalPart: Double {
        return truncatingRemainder(dividingBy: 1.0)
    }
    
    /// Returns a truncated `Int` equivalent to this value.
    var truncated: Int {
        return Int(trunc(self))
    }
    
}
