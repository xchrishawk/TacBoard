//
//  LocalizableString.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/6/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

// MARK: - LocalizableStringKey

/// Enumeration of keys for localized strings.
enum LocalizableStringKey: String {

    // MARK: Cases (Generic)
    
    case genericYes
    case genericNo
    case genericOK
    case genericCancel
    case genericReset
    case genericNA
    case genericOther
    case genericSelected
    case genericVersion
    case genericDebug
    case genericRelease
    case genericSlashSeparator
    case genericCommaSeparator
    case genericXSeparator
    case genericDegreeSymbol
    case genericNorth
    case genericSouth
    case genericEast
    case genericWest
    case genericNorthLetter
    case genericSouthLetter
    case genericEastLetter
    case genericWestLetter
    case genericChannel
    case genericRunway
    case genericIdentifier
    
    // MARK: Cases (About Page)
    
    case aboutAppInfoSection
    case aboutAppInfoItemName
    case aboutAppInfoItemVersion
    case aboutAppInfoItemBuild
    case aboutAppInfoItemType
    case aboutAppInfoItemDate
    case aboutAppInfoItemCommit
    case aboutDataInfoSection
    case aboutDataInfoItemAirports
    case aboutDataInfoItemChecklists
    case aboutDataInfoItemReference
    case aboutDataInfoCheckForUpdatedData
    case aboutDebugSection
    case aboutDebugUseFallbackData
    case aboutDebugUseLocalData
    case aboutDebugUseStagingData
    case aboutDebugUseProductionData
    case aboutReloadingDataTitle
    case aboutReloadingDataMessage

    // MARK: Cases (Airports)
    
    case airportChartDisclaimer
    case airportDetailItemIdentifier
    case airportDetailItemCallsign
    case airportDetailItemName
    case airportDetailItemType
    case airportDetailItemTACAN
    case airportDetailItemILS
    case airportDetailItemCity
    case airportDetailItemCountry
    case airportDetailItemLatLon
    case airportDetailItemElevation
    case airportDetailItemMagneticVariation
    case airportDetailSectionInformation
    case airportDetailSectionLocation
    case airportDetailSectionImages
    case airportDetailSectionNavigation
    case airportDetailSectionCommunications
    case airportDetailSectionRunways
    case airportListEnableTerrainModule
    case airportListNoMatches
    case airportTypeCivilian
    case airportTypeMilitary
    
    // MARK: Cases (Checklists)
    
    case checklistBinderEnableAircraftModule
    case checklistBinderNoMatches
    case checklistFoldersSectionTitle
    case checklistProceduresSectionTitle
    case checklistResetAllAlertBinderMessage
    case checklistResetAllAlertFolderMessage
    case checklistResetAllAlertTitle
    
    // MARK: Cases (DisplayMode)
    
    case displayModeAuto
    case displayModeDay
    case displayModeNight
    
    // MARK: Cases (Home)

    case homeAboutPage
    case homeSettingsPage
    case homeHelpPage
    case homeAllModulesPage
    case homeEnabledAircraftModulesSectionTitle
    case homeEnabledTerrainModulesSectionTitle
    case homeAppUpdated
    
    // MARK: Cases (ISO3166)
    
    case iso3166Georgia
    case iso3166Russia
    case iso3166UnitedStates
    
    // MARK: Cases (LatLon.Format)
    
    case latLonFormatDegrees
    case latLonFormatDegreesMinutes
    case latLonFormatDegreesMinutesSeconds
    
    // MARK: Cases (NavaidType)
    
    case navaidTypeVOR
    case navaidTypeDME
    case navaidTypeVORDME
    case navaidTypeTACAN
    case navaidTypeVORTAC
    case navaidTypeRSBN
    case navaidTypeNDB
    case navaidTypeInnerMarker
    case navaidTypeOuterMarker
    case navaidTypeILS
    case navaidTypePRMG
    case navaidTypeICLS

    // MARK: Cases (NineLineCAS)
    
    case nineLineCASItem1
    case nineLineCASItem1Short
    case nineLineCASItem2
    case nineLineCASItem2Short
    case nineLineCASItem3
    case nineLineCASItem3Short
    case nineLineCASItem4
    case nineLineCASItem4Short
    case nineLineCASItem5
    case nineLineCASItem5Short
    case nineLineCASItem6
    case nineLineCASItem6Short
    case nineLineCASItem7
    case nineLineCASItem7Short
    case nineLineCASItem8
    case nineLineCASItem8Short
    case nineLineCASItem9
    case nineLineCASItem9Short
    case nineLineCASRemarks
    case nineLineCASRemarksShort
    
    // MARK: Cases (NotepadPage)
    
    case notepadPageBlank1
    case notepadPageBlank2
    case notepadPageNineLineCAS
    
    // MARK: Cases (RadioFrequencyBand)
    
    case radioFrequencyBandHF
    case radioFrequencyBandVHFLow
    case radioFrequencyBandVHFHigh
    case radioFrequencyBandUHF
    
    // MARK: Cases (RadioModulationType)
    
    case radioModulationTypeAM
    case radioModulationTypeFM
    case radioModulationTypeAMFM
    
    // MARK: Cases (Reference)
    
    case referenceBinderNoMatches
    case referenceFoldersSectionTitle
    case referenceDocumentDisclaimer
    case referenceDocumentsSectionTitle
    
    // MARK: Cases (Settings)
    
    case settingsResetAlertTitle
    case settingsResetAlertMessage
    
    // MARK: Cases (TerrainModule)
    
    case terrainModuleCaucasus
    case terrainModuleNevada
    case terrainModuleNormandy
    case terrainModulePersianGulf
    case terrainModuleTheChannel
    
    // MARK: Cases (UnitFormat)
    
    case unitFormatImperial
    case unitFormatMetric
    
    // MARK: Properties
    
    /// The lookup key for this localized string.
    var key: String {
        return rawValue
    }
    
    /// The table name for this localized string.
    var tableName: String? {
        return nil
    }
    
    /// The default value for this localized string.
    var value: String {
        #if DEBUG
            return "!!!MISSING LOCALIZED STRING!!!"
        #else
            return String()
        #endif
    }
    
    /// The comment for this localized string.
    var comment: String {
        return value
    }
    
}

// MARK: - Functions

/// Returns a localized string with the specified key.
func LocalizableString(_ key: LocalizableStringKey) -> String {
    return NSLocalizedString(key.key, tableName: key.tableName, bundle: .main, value: key.value, comment: key.comment)
}
