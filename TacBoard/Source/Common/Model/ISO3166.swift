//
//  ISO3166.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/4/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Enumeration of ISO-3166 country codes.
enum ISO3166: String, Codable {
    
    // MARK: Cases
    
    /// Country code for Georgia.
    case ge = "GE"
    
    /// Country code for Russia.
    case ru = "RU"
    
    /// Country code for the United States.
    case us = "US"
    
    // MARK: Properties
    
    /// Returns the flag emoji for this country.
    var flag: String {
        switch self {
        case .ge: return "🇬🇪"
        case .ru: return "🇷🇺"
        case .us: return "🇺🇸"
        }
    }
    
    /// Returns the name of this country.
    var name: String {
        switch self {
        case .ge: return LocalizableString(.iso3166Georgia)
        case .ru: return LocalizableString(.iso3166Russia)
        case .us: return LocalizableString(.iso3166UnitedStates)
        }
    }
    
}
