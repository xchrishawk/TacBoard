//
//  AirportRunway.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/4/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Class containing information about a specific runway at an airport.
class AirportRunway: Decodable {
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified values.
    init(identifier: String,
         reciprocalIdentifier: String,
         heading: Double,
         reciprocalHeading: Double,
         length: Double,
         width: Double) {
     
        self.identifier = identifier
        self.reciprocalIdentifier = reciprocalIdentifier
        self.heading = Measurement(value: heading, unit: .degrees)
        self.reciprocalHeading = Measurement(value: reciprocalHeading, unit: .degrees)
        self.length = Measurement(value: length, unit: .feet)
        self.width = Measurement(value: width, unit: .feet)
        
    }
    
    // MARK: Properties

    /// The identifier of the runway.
    let identifier: String
    
    /// The identifier of the reciprocal runway.
    let reciprocalIdentifier: String
    
    /// The heading of the runway.
    let heading: Measurement<UnitAngle>
    
    /// The reciprocal heading of the runway.
    let reciprocalHeading: Measurement<UnitAngle>
    
    /// The length of the runway.
    let length: Measurement<UnitLength>
    
    /// The width of the runway.
    let width: Measurement<UnitLength>
    
    // MARK: Codable
    
    /// `CodingKey` enum for this class.
    private enum CodingKeys: String, CodingKey {
        case identifier
        case reciprocalIdentifier
        case heading
        case reciprocalHeading
        case length
        case width
    }
    
    /// Initializes a new instance with the specified decoder.
    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(identifier: try container.decode(String.self, forKey: .identifier),
                  reciprocalIdentifier: try container.decode(String.self, forKey: .reciprocalIdentifier),
                  heading: try container.decode(Double.self, forKey: .heading),
                  reciprocalHeading: try container.decode(Double.self, forKey: .reciprocalHeading),
                  length: try container.decode(Double.self, forKey: .length),
                  width: try container.decode(Double.self, forKey: .width))
    }
    
}
