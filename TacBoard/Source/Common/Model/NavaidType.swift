//
//  NavaidType.swift
//  TacBoard
//
//  Created by Chris Vig on 9/7/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Enumeration of the available navaid types.
enum NavaidType: String, Codable, CustomStringConvertible {

    // MARK: Cases
    
    /// The navaid is a VOR.
    case VOR
    
    /// The navaid is a DME.
    case DME
    
    /// The navaid is a VOR/DME.
    case VORDME
    
    /// The navaid is a TACAN.
    case TACAN
    
    /// The navaid is a VORTAC.
    case VORTAC
    
    /// The navaid is an RSBN.
    case RSBN
    
    /// The navaid is an NDB.
    case NDB
    
    /// The navaid is an inner marker NDB.
    case innerMarker
    
    /// The navaid is an outer marker NDB.
    case outerMarker
    
    /// The navaid is an ILS.
    case ILS
    
    /// The navaid is a PRMG.
    case PRMG
    
    /// The navaid is an ICLS.
    case ICLS
    
    // MARK: CustomStringConvertible
    
    /// Returns a `String` description of this enum.
    var description: String {
        switch self {
        case .VOR:
            return LocalizableString(.navaidTypeVOR)
        case .DME:
            return LocalizableString(.navaidTypeDME)
        case .VORDME:
            return LocalizableString(.navaidTypeVORDME)
        case .TACAN:
            return LocalizableString(.navaidTypeTACAN)
        case .VORTAC:
            return LocalizableString(.navaidTypeVORTAC)
        case .RSBN:
            return LocalizableString(.navaidTypeRSBN)
        case .NDB:
            return LocalizableString(.navaidTypeNDB)
        case .innerMarker:
            return LocalizableString(.navaidTypeInnerMarker)
        case .outerMarker:
            return LocalizableString(.navaidTypeOuterMarker)
        case .ILS:
            return LocalizableString(.navaidTypeILS)
        case .PRMG:
            return LocalizableString(.navaidTypePRMG)
        case .ICLS:
            return LocalizableString(.navaidTypeICLS)
        }
    }
    
    /// The sorting order for this enum.
    var sortOrder: Int {
        switch self {
        case .ILS: return 0
        case .ICLS: return 1
        case .RSBN: return 2
        case .PRMG: return 3
        case .TACAN: return 4
        case .VORTAC: return 5
        case .VORDME: return 6
        case .VOR: return 7
        case .NDB: return 8
        case .outerMarker: return 9
        case .innerMarker: return 10
        case .DME: return 11
        }
    }
    
}
