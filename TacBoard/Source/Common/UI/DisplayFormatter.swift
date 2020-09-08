//
//  DisplayFormatter.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/7/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Utility class for generating display strings from numeric values.
class DisplayFormatter {

    // MARK: Fields
    
    private let queue = DispatchQueue(label: "DisplayFormatter")
    private let numberFormatter = NumberFormatter()
    private let measurementFormatter = MeasurementFormatter()
    
    // MARK: Initialization/Singleton
    
    /// The shared instance of the `DisplayFormatter` class.
    static let shared = DisplayFormatter()
    
    /// Class is not publicly instantiable.
    private init() { }
    
    // MARK: Methods
    
    /// Returns a `String` for the specified `Double`.
    func string(for value: Double?,
                minimumIntegerDigits: Int = 1,
                minimumFractionDigits: Int = 0,
                maximumFractionDigits: Int = 0,
                usesGroupingSeparator: Bool = false) -> String {
        
        var result = LocalizableString(.genericNA)
        
        if let value = value {
            queue.sync {
                
                numberFormatter.numberStyle = .decimal
                numberFormatter.minimumIntegerDigits = minimumIntegerDigits
                numberFormatter.minimumFractionDigits = minimumFractionDigits
                numberFormatter.maximumFractionDigits = max(minimumFractionDigits, maximumFractionDigits)
                numberFormatter.usesGroupingSeparator = usesGroupingSeparator
                
                if let formatted = numberFormatter.string(from: NSNumber(value: value)) {
                    result = formatted
                }
                
            }
        }
        
        return result
        
    }
    
    /// Returns a `String` for the specified `Measurement`.
    func string<UnitType>(for measurement: Measurement<UnitType>?,
                          displayUnit: UnitType? = nil,
                          minimumIntegerDigits: Int = 1,
                          minimumFractionDigits: Int = 0,
                          maximumFractionDigits: Int = 0,
                          usesGroupingSeparator: Bool = false) -> String where UnitType: Dimension {
        
        var result = LocalizableString(.genericNA)
        
        if let measurement = measurement {
            queue.sync {
             
                numberFormatter.numberStyle = .decimal
                numberFormatter.minimumIntegerDigits = minimumIntegerDigits
                numberFormatter.minimumFractionDigits = minimumFractionDigits
                numberFormatter.maximumFractionDigits = max(minimumFractionDigits, maximumFractionDigits)
                numberFormatter.usesGroupingSeparator = usesGroupingSeparator
                
                let measurementFormatter = MeasurementFormatter()
                measurementFormatter.numberFormatter = numberFormatter
                measurementFormatter.unitOptions = [.providedUnit]
                measurementFormatter.unitStyle = (UnitType.self == UnitAngle.self ? .short : .medium) // for angles, we want the degree symbol specifically
                
                let converted: Measurement<UnitType> = {
                    guard let displayUnit = displayUnit else { return measurement }
                    return measurement.converted(to: displayUnit)
                }()
                
                result = measurementFormatter.string(from: converted)

            }
        }
        
        return result
        
    }
    
    /// Returns a display string for the specified latitude with the specified format.
    func string(forLatitude latitude: LatLonComponent, format: LatLon.Format) -> String {
        return string(forLatitudeOrLongitude: latitude.degrees,
                      format: format,
                      positiveLabel: LocalizableString(.genericNorthLetter),
                      negativeLabel: LocalizableString(.genericSouthLetter),
                      minimumIntegerDigitsForDegrees: 2)
    }
    
    /// Returns a display string for the specified longitude with the specified format.
    func string(forLongitude longitude: LatLonComponent, format: LatLon.Format) -> String {
        return string(forLatitudeOrLongitude: longitude.degrees,
                      format: format,
                      positiveLabel: LocalizableString(.genericEastLetter),
                      negativeLabel: LocalizableString(.genericWestLetter),
                      minimumIntegerDigitsForDegrees: 3)
    }
    
    /// Returns a display string for the specified magnetic variation.
    func string(forMagneticVariation magneticVariation: Measurement<UnitAngle>) -> String {
        return string(forLatitudeOrLongitude: magneticVariation.converted(to: .degrees).value,
                      format: .degrees,
                      positiveLabel: LocalizableString(.genericEastLetter),
                      negativeLabel: LocalizableString(.genericWestLetter),
                      minimumFractionDigitsForDegrees: 0)
    }
    
    // MARK: Private Utility
    
    /// Returns a latitude or longitude string with the specified parameters.
    private func string(forLatitudeOrLongitude degrees: Double,
                        format: LatLon.Format,
                        positiveLabel: String,
                        negativeLabel: String,
                        minimumIntegerDigitsForDegrees: Int = 0,
                        minimumFractionDigitsForDegrees: Int = 3) -> String {
        
        let label = (degrees.isNegative ? negativeLabel : positiveLabel)

        switch format {
         
        case .degrees:
            let degreesString = string(for: abs(degrees),
                                       minimumIntegerDigits: minimumIntegerDigitsForDegrees,
                                       minimumFractionDigits: minimumFractionDigitsForDegrees,
                                       maximumFractionDigits: 6)
            return "\(label) \(degreesString)\(UnitAngle.degrees.symbol)"
            
        case .degreesMinutes:
            let minutes = degrees.fractionalPart * LatLonComponent.minutesPerDegree
            let degreesString = string(for: Double(abs(degrees.truncated)),
                                       minimumIntegerDigits: minimumIntegerDigitsForDegrees,
                                       minimumFractionDigits: 0,
                                       maximumFractionDigits: 0)
            let minutesString = string(for: abs(minutes),
                                       minimumIntegerDigits: 2,
                                       minimumFractionDigits: 3,
                                       maximumFractionDigits: 3)
            return "\(label) \(degreesString)\(UnitAngle.degrees.symbol) \(minutesString)\(UnitAngle.arcMinutes.symbol)"
            
        case .degreesMinutesSeconds:
            let minutes = degrees.fractionalPart * LatLonComponent.minutesPerDegree
            let seconds = minutes.fractionalPart * LatLonComponent.secondsPerMinute
            let degreesString = string(for: Double(abs(degrees).truncated),
                                       minimumIntegerDigits:  minimumIntegerDigitsForDegrees,
                                       minimumFractionDigits: 0,
                                       maximumFractionDigits: 0)
            let minutesString = string(for: Double(abs(minutes).truncated),
                                       minimumIntegerDigits: 2,
                                       minimumFractionDigits: 0,
                                       maximumFractionDigits: 0)
            let secondsString = string(for: abs(seconds),
                                       minimumIntegerDigits: 2,
                                       minimumFractionDigits: 1,
                                       maximumFractionDigits: 1)
            return "\(label) \(degreesString)\(UnitAngle.degrees.symbol) \(minutesString)\(UnitAngle.arcMinutes.symbol) \(secondsString)\(UnitAngle.arcSeconds.symbol)"
            
        }
        
    }
    
}
