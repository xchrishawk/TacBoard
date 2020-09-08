//
//  ReferenceEquatable.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/15/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Protocol for objects implementing `Equatable` by checking reference equality.
protocol ReferenceEquatable: class, Equatable { }

extension ReferenceEquatable {

    /// Equality operator performing a reference comparison.
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return (lhs === rhs)
    }
    
}
