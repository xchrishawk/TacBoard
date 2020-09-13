//
//  SettingsManager.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/2/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import UIKit

// MARK: - Setting

/// Enumeration of the available settings.
fileprivate enum Setting: String {
 
    // MARK: Cases
    
    /// The currently enabled aircraft modules.
    case enabledAircraftModules
    
    /// The currently enabled terrain modules.
    case enabledTerrainModules
    
    /// The currently selected display mode.
    case displayMode
    
    /// The currently selected unit format.
    case unitFormat
    
    /// The currently selected latitude/longitude format.
    case latLonFormat
    
    /// The split display mode for the airport page.
    case airportSplitDisplayMode
    
    /// The brightness to use for airport images in dark mode.
    case airportDarkModeBrightness
    
    /// The split display mode for the checklist page.
    case checklistSplitDisplayMode
    
    /// The currently selected notepad page.
    case notepadSelectedPage
    
    /// The currently active notepad path color.
    case notepadActivePathColor
    
    /// The currently active notepad path width.
    case notepadActivePathWidth
    
    /// The split display mode for the reference page.
    case referenceSplitDisplayMode
    
    /// The brightness to use for reference pages in dark mode.
    case referenceDarkModeBrightness
    
    // MARK: Properties
    
    /// The namespaced key for this setting.
    var key: String {
        return "so.invictus.TacBoard.SettingsManager.\(rawValue)"
    }
    
}

// MARK: - SettingsManager

/// Singleton class for managing application settings.
class SettingsManager {

    // MARK: Initialization/Singleton
    
    /// The shared instance of the `SettingsManager` class.
    static let shared = SettingsManager()
    
    /// Not publicly instantiable.
    private init(defaults: UserDefaults = UserDefaults.standard) {
        self.enabledAircraftModules = defaults.mutableProperty(setting: .enabledAircraftModules, defaultValue: Set(AircraftModule.defaultEnabledModules))
        self.enabledTerrainModules = defaults.mutableProperty(setting: .enabledTerrainModules, defaultValue: Set(TerrainModule.defaultEnabledModules))
        self.displayMode = defaults.mutableProperty(setting: .displayMode)
        self.unitFormat = defaults.mutableProperty(setting: .unitFormat)
        self.latLonFormat = defaults.mutableProperty(setting: .latLonFormat)
        self.airportSplitDisplayMode = defaults.mutableProperty(setting: .airportSplitDisplayMode)
        self.airportDarkModeBrightness = defaults.mutableProperty(setting: .airportDarkModeBrightness, defaultValue: Constants.defaultDarkModeBrightness)
        self.checklistSplitDisplayMode = defaults.mutableProperty(setting: .checklistSplitDisplayMode)
        self.notepadSelectedPage = defaults.mutableProperty(setting: .notepadSelectedPage)
        self.notepadActivePathColor = defaults.mutableProperty(setting: .notepadActivePathColor, defaultValue: NotepadPath.defaultColor)
        self.notepadActivePathWidth = defaults.mutableProperty(setting: .notepadActivePathWidth, defaultValue: NotepadPath.defaultWidth)
        self.referenceSplitDisplayMode = defaults.mutableProperty(setting: .referenceSplitDisplayMode)
        self.referenceDarkModeBrightness = defaults.mutableProperty(setting: .referenceDarkModeBrightness, defaultValue: Constants.defaultDarkModeBrightness)
    }
    
    // MARK: Properties
    
    /// The set of currently enabled aircraft modules.
    let enabledAircraftModules: MutableProperty<Set<AircraftModule>>
    
    /// The set of currently enabled terrain modules.
    let enabledTerrainModules: MutableProperty<Set<TerrainModule>>
    
    /// The currently selected display mode.
    let displayMode: MutableProperty<DisplayMode>
    
    /// The currently selected unit format.
    let unitFormat: MutableProperty<UnitFormat>
    
    /// The currently selected latitude/longitude format.
    let latLonFormat: MutableProperty<LatLon.Format>
    
    /// The split display mode for the Airport page.
    let airportSplitDisplayMode: MutableProperty<SplitDisplayMode>
    
    /// The brightness to use for airport images in dark mode.
    let airportDarkModeBrightness: MutableProperty<CGFloat>
    
    /// The split display mode for the Checklist page.
    let checklistSplitDisplayMode: MutableProperty<SplitDisplayMode>
    
    /// The currently selected Notepad page.
    let notepadSelectedPage: MutableProperty<NotepadPage>
    
    /// The currently active notepad color.
    let notepadActivePathColor: MutableProperty<UIColor>
    
    /// The currently active notepad path width.
    let notepadActivePathWidth: MutableProperty<CGFloat>
    
    /// The split display mode for the Reference page.
    let referenceSplitDisplayMode: MutableProperty<SplitDisplayMode>
    
    /// The brightness to use for reference pages in dark mode.
    let referenceDarkModeBrightness: MutableProperty<CGFloat>
    
    // MARK: Methods
    
    /// Resets all settings to their default state.
    func reset() {
        enabledAircraftModules.value = Set(AircraftModule.defaultEnabledModules)
        enabledTerrainModules.value = Set(TerrainModule.defaultEnabledModules)
        displayMode.value = .default
        unitFormat.value = .default
        latLonFormat.value = .default
        airportSplitDisplayMode.value = .default
        airportDarkModeBrightness.value = Constants.defaultDarkModeBrightness
        checklistSplitDisplayMode.value = .default
        notepadSelectedPage.value = .default
        notepadActivePathColor.value = NotepadPath.defaultColor
        notepadActivePathWidth.value = NotepadPath.defaultWidth
        referenceSplitDisplayMode.value = .default
        referenceDarkModeBrightness.value = Constants.defaultDarkModeBrightness
    }
    
}

// MARK: - UserDefaults

fileprivate extension UserDefaults {
    
    // MARK: Types
    
    /// Type alias for serializable enums.
    typealias EnumType = Defaultable & RawRepresentable
    
    // MARK: Methods
    
    /// Returns a `CGFloat` value for the specified `Setting`.
    func get(setting: Setting, defaultValue: CGFloat) -> CGFloat {
        guard let number = value(forKey: setting.key) as? NSNumber else { return defaultValue }
        return CGFloat(number.doubleValue)
    }
    
    /// Returns a `MutableProperty<CGFloat>` for the specified `Setting`.
    func mutableProperty(setting: Setting, defaultValue: CGFloat) -> MutableProperty<CGFloat> {
        return mutableProperty(value: get(setting: setting, defaultValue: defaultValue)) { defaults, value in
            defaults.set(NSNumber(value: Double(value)), forKey: setting.key)
        }
    }
    
    /// Returns an `EnumType` value for the specified `Setting`.
    func get<T>(setting: Setting) -> T where T: EnumType, T.RawValue == String {
        guard
            let rawValue = string(forKey: setting.key),
            let value = T(rawValue: rawValue)
            else { return T.default }
        return value
    }
    
    /// Returns a `MutableProperty<EnumType>` for the specified `Setting`.
    func mutableProperty<T>(setting: Setting) -> MutableProperty<T> where T: EnumType, T.RawValue == String {
        return mutableProperty(value: get(setting: setting)) { defaults, value in
            defaults.set(value.rawValue, forKey: setting.key)
        }
    }
    
    /// Returns a `Set<T>` for the specified `Setting`.
    func get<T>(setting: Setting, defaultValue: Set<T>) -> Set<T> where T: Module {
        guard
            let rawValues = object(forKey: setting.key) as? [String]
            else { return defaultValue }
        return Set(rawValues.compactMap { T.for(key: $0) })
    }
    
    /// Returns a `MutableProperty<Set<T>>` for the specified `Setting`.
    func mutableProperty<T>(setting: Setting, defaultValue: Set<T>) -> MutableProperty<Set<T>> where T: Module {
        return mutableProperty(value: get(setting: setting, defaultValue: defaultValue)) { defaults, value in
            defaults.set(value.map { $0.key }, forKey: setting.key)
        }
    }
    
    /// Returns a `T: NSSecureCoding` value for the specified `Setting`.
    func get<T>(setting: Setting, defaultValue: T) -> T where T: NSSecureCoding {
        guard
            let data = self.data(forKey: setting.key),
            let value = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [T.self], from: data) as? T
            else { return defaultValue }
        return value
    }
    
    /// Returns a `MutableProperty<T: NSSecureCoding>` for the specified `Setting`.
    func mutableProperty<T>(setting: Setting, defaultValue: T) -> MutableProperty<T> where T: NSSecureCoding {
        return mutableProperty(value: get(setting: setting, defaultValue: defaultValue)) { defaults, value in
            guard
                let data = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true)
                else { return }
            defaults.set(data, forKey: setting.key)
        }
    }
    
    // MARK: Private Utility
    
    /// Returns a `MutableProperty` with the specified initial value which calls the specified closure for any update.
    private func mutableProperty<T>(value: T, update: @escaping (UserDefaults, T) -> Void) -> MutableProperty<T> {
        let property = MutableProperty(value)
        property.producer.take(duringLifetimeOf: self).startWithValues { [unowned self] value in update(self, value) }
        return property
    }

}
