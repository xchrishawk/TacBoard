//
//  AirportFrequencyBand.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/6/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Enumeration of airport communications frequency bands.
enum FrequencyBand: String, Codable, CustomStringConvertible {

    // MARK: Cases
    
    /// HF frequency band.
    case hf = "HF"
    
    /// Low VHF frequency band.
    case vhfLow = "VHFLow"
    
    /// High VHF frequency band.
    case vhfHigh = "VHFHigh"
    
    /// UHF frequency band.
    case uhf = "UHF"
    
    // MARK: Properties
    
    /// Returns a `String` description of this enum.
    var description: String {
        switch self {
        case .hf:
            return LocalizableString(.airportFrequencyBandHF)
        case .vhfLow:
            return LocalizableString(.airportFrequencyBandVHFLow)
        case .vhfHigh:
            return LocalizableString(.airportFrequencyBandVHFHigh)
        case .uhf:
            return LocalizableString(.airportFrequencyBandUHF)
        }
    }
    
}
