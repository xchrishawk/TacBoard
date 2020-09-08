//
//  TerrainModule.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/7/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Enumeration of the terrain modules supported by DCS.
final class TerrainModule: Module {
    
    // MARK: Constants
    
    /// An array of all available terrain modules.
    static var all: [TerrainModule] = {
        
        guard
            let url = Bundle.main.url(forResource: "TerrainModules", withExtension: "json")
            else { fatalInvalidResource() }
        
        do {
            let modules = try [TerrainModule].loadFromJSON(url: url)
            return modules.sorted { $0.title < $1.title }
        } catch {
            NSLog("Failed to deserialize terrain modules! \(error)")
            fatalInvalidResource()
        }
        
    }()
    
    // MARK: Properties
    
    /// Returns a `UIImage` representing the icon for this terrain module.
    lazy var icon: UIImage? = {
        return UIImage(named: "Icon-TerrainModule-\(self.key)") ?? UIImage(named: "Icon-TerrainModule-Generic")
    }()
    
}
