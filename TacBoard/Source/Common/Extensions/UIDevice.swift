//
//  UIDevice.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    
    /// Returns `true` if the current `userInterfaceIdiom` is `.phone`.
    var isPhone: Bool {
        return userInterfaceIdiom == .phone
    }
    
}
