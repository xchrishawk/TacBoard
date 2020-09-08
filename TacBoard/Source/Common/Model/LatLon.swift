//
//  LatLon.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/22/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

// MARK: - LatLon

/// Struct containing a latitude/longitude coordinate.
struct LatLon: Decodable {
    
    // MARK: Types
    
    /// Enumeration of supported latitude/longitude formats.
    enum Format: String, CaseIterable, CustomStringConvertible, Defaultable {
        
        // MARK: Cases
        
        /// Only degrees are displayed.
        case degrees
        
        /// Degrees and minutes are displayed.
        case degreesMinutes
        
        /// Degrees, minutes, and seconds are displayed.
        case degreesMinutesSeconds
        
        // MARK: Constants
        
        /// The default lat/lon format.
        static let `default`: LatLon.Format = .degreesMinutes // since this is what the A-10 EGI uses
        
        // MARK: Properties
        
        /// Returns a `String` description of this enum.
        var description: String {
            switch self {
            case .degrees:
                return LocalizableString(.latLonFormatDegrees)
            case .degreesMinutes:
                return LocalizableString(.latLonFormatDegreesMinutes)
            case .degreesMinutesSeconds:
                return LocalizableString(.latLonFormatDegreesMinutesSeconds)
            }
        }
        
    }

    // MARK: Initialization
    
    /// Initializes a new instance with the specified latitude and longitude.
    init(latitude: LatLonComponent, longitude: LatLonComponent) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // MARK: Fields
    
    /// The latitude of the the coordinate.
    let latitude: LatLonComponent
    
    /// The longitude of the coordinate.
    let longitude: LatLonComponent
    
    // MARK: Decodable
    
    /// `CodingKey` enum for this type.
    private enum CodingKeys: String, CodingKey {
        case lat
        case lon
    }
    
    /// Initializes a new instance with the specified `Decoder`.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(latitude: try container.decode(LatLonComponent.self, forKey: .lat),
                  longitude: try container.decode(LatLonComponent.self, forKey: .lon))
    }
    
}

// MARK: - LatLonComponent

/// Struct representing a single component in a latitude/longitude coordinate.
struct LatLonComponent: Decodable {
    
    // MARK: Constants
    
    /// The number of minutes per degree.
    static let minutesPerDegree = 60.0
    
    /// The number of seconds per minute.
    static let secondsPerMinute = 60.0
    
    /// The number of seconds per degree.
    static let secondsPerDegree = (secondsPerMinute * minutesPerDegree)

    // MARK: Initialization
    
    /// Initializes a new instance with the specified degrees.
    init(degrees: Double) {
        self.degrees = degrees
    }
    
    /// Initializes a new instance with the specified degrees and minutes.
    /// - note: `degrees` and `minutes` must have the same sign.
    init(degrees: Int, minutes: Double) {
        
        guard
            degrees.isNegative == minutes.isNegative
            else { fatalError() }
        
        self.init(degrees: Double(degrees) + (minutes / LatLonComponent.minutesPerDegree))
        
    }
    
    /// Initializes a new instance with the specified degrees, minutes, and seconds.
    /// - note: `degrees`, `minutes`, and `seconds` must have the same sign.
    init(degrees: Int, minutes: Int, seconds: Double) {
        
        guard
            degrees.isNegative == minutes.isNegative,
            degrees.isNegative == seconds.isNegative
            else { fatalError() }
        
        self.init(degrees: Double(degrees) + (Double(minutes) / LatLonComponent.minutesPerDegree) + (seconds / LatLonComponent.secondsPerDegree))
        
    }
    
    // MARK: Properties
    
    /// The degrees in this component.
    /// - note: This includes minutes and seconds.
    let degrees: Double
    
    /// The truncated degrees in this component.
    /// - note: This does not include minutes or seconds.
    var degreesInt: Int { degrees.truncated }
    
    /// The minutes in this component.
    /// - note: This includes seconds.
    var minutes: Double { degrees.fractionalPart * LatLonComponent.minutesPerDegree }
    
    /// The truncated minutes in this component.
    /// - note: This does not include seconds.
    var minutesInt: Int { minutes.truncated }
    
    /// The seconds in this component.
    var seconds: Double { minutes.fractionalPart * LatLonComponent.secondsPerMinute }
    
    // MARK: Codable
    
    /// `CodingKey` enum for this type.
    private enum CodingKeys: String, CodingKey {
        case dir
        case deg
        case min
        case sec
    }
    
    /// Initializes a new instance with the specified `Decoder`.
    init(from decoder: Decoder) throws {
        
        let positiveDirections: Set<String> = ["N", "E"]
        let negativeDirections: Set<String> = ["S", "W"]
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
  
        // e.g., { "dir": "N", "deg": 44, "min": 20, "sec": 14.2 }
        if
            let sec = try? container.decode(Double.self, forKey: .sec),
            let min = try? container.decode(Int.self, forKey: .min),
            let deg = try? container.decode(Int.self, forKey: .deg),
            let dir = try? container.decode(String.self, forKey: .dir),
            !sec.isNegative,
            !min.isNegative,
            !deg.isNegative,
            sec.absolute < LatLonComponent.secondsPerMinute,
            min.absolute < Int(LatLonComponent.minutesPerDegree),
            positiveDirections.contains(dir) || negativeDirections.contains(dir) {
         
            let isNegative = negativeDirections.contains(dir)
            self.init(degrees: isNegative ? deg.negative : deg,
                      minutes: isNegative ? min.negative : min,
                      seconds: isNegative ? sec.negative : sec)
            
        }
        
        // e.g., { "deg": 44, "min": 20, "sec": 14.2 }
        else if
            let sec = try? container.decode(Double.self, forKey: .sec),
            let min = try? container.decode(Int.self, forKey: .min),
            let deg = try? container.decode(Int.self, forKey: .deg),
            !container.contains(.dir),
            sec.isNegative == deg.isNegative,
            min.isNegative == deg.isNegative,
            sec.absolute < LatLonComponent.secondsPerMinute,
            min.absolute < Int(LatLonComponent.minutesPerDegree) {
         
            self.init(degrees: deg, minutes: min, seconds: sec)
            
        }
                    
        // e.g., { "dir": "N", "deg": 44, "min": 20.4 }
        else if
            !container.contains(.sec),
            let min = try? container.decode(Double.self, forKey: .min),
            let deg = try? container.decode(Int.self, forKey: .deg),
            let dir = try? container.decode(String.self, forKey: .dir),
            !min.isNegative,
            !deg.isNegative,
            min.absolute < LatLonComponent.minutesPerDegree,
            positiveDirections.contains(dir) || negativeDirections.contains(dir) {
         
            let isNegative = negativeDirections.contains(dir)
            self.init(degrees: isNegative ? deg.negative : deg,
                      minutes: isNegative ? min.negative : min)
            
        }
        
        // e.g., { "deg": 44, "min": 20.4 }
        else if
            !container.contains(.sec),
            let min = try? container.decode(Double.self, forKey: .min),
            let deg = try? container.decode(Int.self, forKey: .deg),
            !container.contains(.dir),
            min.isNegative == deg.isNegative,
            min.absolute < LatLonComponent.minutesPerDegree {
         
            self.init(degrees: deg, minutes: min)
            
        }
            
        // e.g., { "dir": "N", "deg": 44.5 }
        else if
            !container.contains(.sec),
            !container.contains(.min),
            let deg = try? container.decode(Double.self, forKey: .deg),
            let dir = try? container.decode(String.self, forKey: .dir),
            !deg.isNegative,
            positiveDirections.contains(dir) || negativeDirections.contains(dir) {
         
            let isNegative = negativeDirections.contains(dir)
            self.init(degrees: isNegative ? deg.negative : deg)
            
        }
        
        // e.g. { "deg": -100.2 }
        else if
            !container.contains(.sec),
            !container.contains(.min),
            let deg = try? container.decode(Double.self, forKey: .deg),
            !container.contains(.dir) {
         
            self.init(degrees: deg)
            
        } else {
         
            // Couldn't find a recognized format
            throw DecodingError.dataCorruptedError(forKey: .deg, in: container, debugDescription: "Data not in a recognized format!")
            
        }
        
    }
    
}
