//
//  RadioFrequencyBand.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/6/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Enumeration of radio frequency bands.
enum RadioFrequencyBand: String, Codable, CustomStringConvertible {

    // MARK: Cases
    
    /// HF frequency band.
    case HF = "HF"
    
    /// Low VHF frequency band.
    case VHFLow = "VHFLow"
    
    /// High VHF frequency band.
    case VHFHigh = "VHFHigh"
    
    /// UHF frequency band.
    case UHF = "UHF"
    
    // MARK: Properties
    
    /// Returns a `String` description of this enum.
    var description: String {
        switch self {
        case .HF:
            return LocalizableString(.radioFrequencyBandHF)
        case .VHFLow:
            return LocalizableString(.radioFrequencyBandVHFLow)
        case .VHFHigh:
            return LocalizableString(.radioFrequencyBandVHFHigh)
        case .UHF:
            return LocalizableString(.radioFrequencyBandUHF)
        }
    }
    
}
