//
//  Defaultable.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/3/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Protocol for objects defining a default value.
protocol Defaultable {

    /// The default value for this type.
    static var `default`: Self { get }

}
