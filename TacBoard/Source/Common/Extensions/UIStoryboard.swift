//
//  UIStoryboard.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/22/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {

    struct App {
        
        // MARK: Instantiation
        
        /// Not instantiable.
        private init() { }
        
        // MARK: Constants
        
        /// The `Airports` application storyboard.
        static let airports = UIStoryboard(name: "Airports", bundle: .main)
        
        /// The `Checklists` application storyboard.
        static let checklists = UIStoryboard(name: "Checklists", bundle: .main)
        
        /// The `Common` application storyboard.
        static let common = UIStoryboard(name: "Common", bundle: .main)
        
        /// The `Home` application storyboard.
        static let home = UIStoryboard(name: "Home", bundle: .main)
    
        /// The `LaunchScreen` application storyboard.
        static let launchScreen = UIStoryboard(name: "LaunchScreen", bundle: .main)
        
        /// The `Main` application storyboard.
        static let main = UIStoryboard(name: "Main", bundle: .main)
        
        /// The `Notepad` application storyboard.
        static let notepad = UIStoryboard(name: "Notepad", bundle: .main)
        
        /// The `Reference` application storyboard.
        static let reference = UIStoryboard(name: "Reference", bundle: .main)
        
    }
    
}
