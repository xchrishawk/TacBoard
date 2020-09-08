//
//  UIColor.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/2/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    /// Initializes with the specified color from the application assets.
    convenience init(application: ApplicationColor) {
        self.init(named: application.rawValue)!
    }
    
}
