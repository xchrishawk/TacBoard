//
//  AirportType.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/4/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Enumeration of airport types.
enum AirportType: String, Codable, CustomStringConvertible {

    // MARK: Cases
    
    /// The airport is a civilian airport.
    case civilian = "Civilian"
    
    /// The airport is a military airport.
    case military = "Military"
    
    // MARK: Properties
    
    /// A `String` describing this enum value.
    var description: String {
        switch self {
        case .civilian:
            return LocalizableString(.airportTypeCivilian)
        case .military:
            return LocalizableString(.airportTypeMilitary)
        }
    }
    
}
