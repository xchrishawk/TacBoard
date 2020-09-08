//
//  AirportCommFrequency.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/6/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Class representing an airport communications frequency.
class AirportCommFrequency: Decodable {

    // MARK: Initialization
    
    /// Initializes a new instance with the specified values.
    init(title: String, band: RadioFrequencyBand, modulation: RadioModulationType, frequency: Double) {
        self.title = title
        self.band = band
        self.modulation = modulation
        self.frequency = Measurement(value: frequency, unit: .hertz)
    }
    
    // MARK: Fields
    
    /// The title of the frequencies.
    let title: String
    
    /// The frequency band.
    let band: RadioFrequencyBand
    
    /// The modulation type.
    let modulation: RadioModulationType
    
    /// The frequency.
    let frequency: Measurement<UnitFrequency>
    
    // MARK: Codable
    
    /// `CodingKeys` enum for this class.
    private enum CodingKeys: String, CodingKey {
        case title
        case band
        case modulation
        case frequency
    }
    
    /// Initializes a new instance from the specified `Decoder`.
    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(title: try container.decode(String.self, forKey: .title),
                  band: try container.decode(RadioFrequencyBand.self, forKey: .band),
                  modulation: try container.decode(RadioModulationType.self, forKey: .modulation),
                  frequency: try container.decode(Double.self, forKey: .frequency))
    }
    
}
