//
//  AirportNavaid.swift
//  TacBoard
//
//  Created by Chris Vig on 9/7/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Class representing an airport navaid.
class AirportNavaid: Decodable {

    // MARK: Initialization
    
    /// Initializes a new instance with the specified properties.
    init(type: NavaidType,
         latLon: LatLon? = nil,
         heading: Double? = nil,
         frequency: Double? = nil,
         channel: String? = nil,
         identifier: String? = nil,
         runwayIdentifier: String? = nil,
         offFieldHeading: Double? = nil,
         offFieldDistance: Double? = nil) {
     
        self.type = type
        self.latLon = latLon
        self.heading = heading.map { Measurement(value: $0, unit: .degrees) }
        self.frequency = frequency.map { Measurement(value: $0, unit: .hertz) }
        self.channel = channel
        self.identifier = identifier
        self.runwayIdentifier = runwayIdentifier
        
        if let offFieldHeading = offFieldHeading, let offFieldDistance = offFieldDistance {
            self.offField = (Measurement(value: offFieldHeading, unit: .degrees),
                             Measurement(value: offFieldDistance, unit: .nauticalMiles))
        } else {
            self.offField = nil
        }
        
    }
    
    // MARK: Properties
    
    /// The type of this navaid.
    let type: NavaidType
    
    /// The latitude/longitude of the navaid, or `nil` if it is not available.
    let latLon: LatLon?
    
    /// The direction of the navaid, or `nil` if it has no direction.
    let heading: Measurement<UnitAngle>?
    
    /// The frequency of the navaid, or `nil` if it has no frequency.
    let frequency: Measurement<UnitFrequency>?
    
    /// The channel of the navaid, or `nil` if it has no channel.
    let channel: String?
    
    /// The identifier of the navaid, or `nil` if it has no identifier.
    let identifier: String?
    
    /// The identifier of the runway the navaid is associated with, or `nil` if there is no associated runway.
    let runwayIdentifier: String?
    
    /// If set to a non-`nil` value, the navaid is located off field.
    let offField: (heading: Measurement<UnitAngle>, distance: Measurement<UnitLength>)?
    
    // MARK: Codable
    
    /// `CodingKey` enum for this class.
    private enum CodingKeys: String, CodingKey {
        case type
        case latLon
        case heading
        case frequency
        case channel
        case identifier
        case runwayIdentifier
        case offFieldHeading
        case offFieldDistance
    }

    /// Initializes a new instance with the specified decoder.
    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(type: try container.decode(NavaidType.self, forKey: .type),
                  latLon: try container.decodeOrDefault(LatLon?.self, forKey: .latLon, default: nil),
                  heading: try container.decodeOrDefault(Double?.self, forKey: .heading, default: nil),
                  frequency: try container.decodeOrDefault(Double?.self, forKey: .frequency, default: nil),
                  channel: try container.decodeOrDefault(String?.self, forKey: .channel, default: nil),
                  identifier: try container.decodeOrDefault(String?.self, forKey: .identifier, default: nil),
                  runwayIdentifier: try container.decodeOrDefault(String?.self, forKey: .runwayIdentifier, default: nil),
                  offFieldHeading: try container.decodeOrDefault(Double?.self, forKey: .offFieldHeading, default: nil),
                  offFieldDistance: try container.decodeOrDefault(Double?.self, forKey: .offFieldDistance, default: nil))
    }
    
}


