//
//  ResourceLocation.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/23/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Enumeration of supported resource locations.
enum ResourceLocation {
    
    /// The image is contained in a local asset file.
    case asset(name: String)
    
    /// The image is a path relative to the current content base URL.
    case relative(path: String)
    
}
