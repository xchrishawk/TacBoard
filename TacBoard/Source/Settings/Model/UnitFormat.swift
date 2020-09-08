//
//  UnitFormat.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/6/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Enumeration of supported unit formats.
enum UnitFormat: String, CaseIterable, CustomStringConvertible, Defaultable {

    // MARK: Cases

    /// Imperial (i.e., crappy American) units.
    case imperial
    
    /// Metric (i.e., sane) units.
    case metric
    
    // MARK: Constants
    
    /// The default unit format.
    static let `default`: UnitFormat = .imperial // 🇺🇸
    
    // MARK: Properties
    
    /// Returns a `String` description of this enum.
    var description: String {
        switch self {
        case .imperial:
            return LocalizableString(.unitFormatImperial)
        case .metric:
            return LocalizableString(.unitFormatMetric)
        }
    }
    
}
