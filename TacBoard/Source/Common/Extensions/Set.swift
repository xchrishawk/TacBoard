//
//  Set.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/7/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

extension Set {

    /// Removes `value` from the `Set` if it is currently a member, and inserts it otherwise.
    mutating func toggle(_ value: Element) {
        if contains(value) {
            remove(value)
        } else {
            insert(value)
        }
    }
    
}
