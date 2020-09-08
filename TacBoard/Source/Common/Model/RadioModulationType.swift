//
//  RadioModulationType.swift
//  TacBoard
//
//  Created by Chris Vig on 9/7/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Enumeration of radio modulation types.
enum RadioModulationType: String, Codable, CustomStringConvertible {

    // MARK: Cases
    
    /// Amplitude modulation.
    case AM
    
    /// Frequency modulation.
    case FM
    
    /// Amplitude and frequency modulation.
    case AMFM
    
    // MARK: CustomStringConvertible
    
    /// Returns a `String` description of this enum.
    var description: String {
        switch self {
        case .AM:
            return LocalizableString(.radioModulationTypeAM)
        case .FM:
            return LocalizableString(.radioModulationTypeFM)
        case .AMFM:
            return LocalizableString(.radioModulationTypeAMFM)
        }
    }
    
}
