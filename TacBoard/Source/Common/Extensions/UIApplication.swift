//
//  UIApplication.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {

    /// Returns `true` if the application is currently in landscape orientation.
    var isLandscape: Bool {
        return windows.first?.windowScene?.interfaceOrientation.isLandscape ?? false
    }
    
}
