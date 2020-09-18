//
//  Airport.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/4/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Struct containing information about a specific airport.
class Airport: Decodable {
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified values.
    init(key: DataIndexKey,
         identifier: String,
         type: AirportType,
         callsign: String? = nil,
         name: String,
         unlocalizedName: String? = nil,
         city: String?,
         country: ISO3166,
         latLon: LatLon,
         elevation: Double,
         magneticVariation: Double,
         navaids: [AirportNavaid] = [],
         frequencies: [AirportCommFrequency] = [],
         runways: [AirportRunway] = [],
         images: [AirportImage] = []) {
        
        self.key = key
        self.identifier = identifier
        self.type = type
        self.callsign = callsign
        self.name = name
        self.unlocalizedName = unlocalizedName
        self.city = city
        self.country = country
        self.latLon = latLon
        self.elevation = Measurement(value: elevation, unit: .feet)
        self.magneticVariation = Measurement(value: magneticVariation, unit: .degrees)
        self.navaids = navaids.sorted { $0.type.sortOrder < $1.type.sortOrder }
        self.frequencies = frequencies
        self.runways = runways.sorted { $0.identifier < $1.identifier }
        self.images = images
        
    }
    
    // MARK: Properties
    
    /// A unique key for this airport.
    let key: DataIndexKey
    
    /// The ICAO identifier of this airport.
    let identifier: String
    
    /// The type of this airport.
    let type: AirportType
    
    /// The radio callsign for the airport.
    let callsign: String?
    
    /// The application-locale name of this airport.
    let name: String
    
    /// The local language name of this airport.
    /// - note: This should be set to `nil` if the local name is already in the current user locale.
    let unlocalizedName: String?
    
    /// The city with which this airport is associated, if any.
    let city: String?
    
    /// The country in which this airport is located.
    let country: ISO3166
    
    /// The latitude/longitude of the airport.
    let latLon: LatLon

    /// The elevation of the airport, in feet.
    let elevation: Measurement<UnitLength>
    
    /// The magnetic variation of the airport, in degrees. East is positive.
    let magneticVariation: Measurement<UnitAngle>
    
    /// The navaids associated with this airport, if any.
    let navaids: [AirportNavaid]
    
    /// The communication frequencies associated with this airport.
    let frequencies: [AirportCommFrequency]
    
    /// The runways at this airport.
    let runways: [AirportRunway]

    /// The images associated with this airport.
    let images: [AirportImage]

    // MARK: Codable
    
    /// `CodingKey` enum for this class.
    private enum CodingKeys: String, CodingKey {
        case identifier
        case type
        case callsign
        case name
        case unlocalizedName
        case city
        case country
        case latLon
        case elevation
        case magneticVariation
        case navaids
        case frequencies
        case runways
        case images
    }
    
    /// Initializes a new instance with the specified `Decoder`.
    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(key: AirportDataIndex.key(for: decoder),
                  identifier: try container.decode(String.self, forKey: .identifier),
                  type: try container.decode(AirportType.self, forKey: .type),
                  callsign: try container.decodeOrDefault(String?.self, forKey: .callsign, default: nil),
                  name: try container.decode(String.self, forKey: .name),
                  unlocalizedName: try container.decodeOrDefault(String?.self, forKey: .unlocalizedName, default: nil),
                  city: try container.decode(String?.self, forKey: .city),
                  country: try container.decode(ISO3166.self, forKey: .country),
                  latLon: try container.decode(LatLon.self, forKey: .latLon),
                  elevation: try container.decode(Double.self, forKey: .elevation),
                  magneticVariation: try container.decode(Double.self, forKey: .magneticVariation),
                  navaids: try container.decodeOrDefault([AirportNavaid].self, forKey: .navaids, default: []),
                  frequencies: try container.decodeOrDefault([AirportCommFrequency].self, forKey: .frequencies, default: []),
                  runways: try container.decodeOrDefault([AirportRunway].self, forKey: .runways, default: []),
                  images: try container.decodeOrDefault([AirportImage].self, forKey: .images, default: []))
    }

}
