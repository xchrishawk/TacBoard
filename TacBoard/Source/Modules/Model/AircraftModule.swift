//
//  AircraftModule.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/7/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Enumeration of the aircraft modules supported by DCS.
final class AircraftModule: Module {

    // MARK: Constants
    
    /// An array of all available aircraft modules.
    static var all: [AircraftModule] = {
        
        guard
            let url = Bundle.main.url(forResource: "AircraftModules", withExtension: "json")
            else { fatalInvalidResource() }
        
        do {
            let modules = try [AircraftModule].loadFromJSON(url: url)
            return modules.sorted { $0.title < $1.title }
        } catch {
            NSLog("Failed to deserialize aircraft modules! \(error)")
            fatalInvalidResource()
        }
        
    }()
    
    // MARK: Properties
    
    /// A `UIImage` representing the icon for this module.
    lazy var icon: UIImage? = {
        return UIImage(named: "Icon-AircraftModule-\(key)") ?? UIImage(named: "Icon-AircraftModule-Generic")
    }()
    
}
