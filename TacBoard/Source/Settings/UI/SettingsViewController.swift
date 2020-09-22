//
//  SettingsViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/2/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// View controller for settings.
class SettingsViewController: TableViewController {

    // MARK: Fields
    
    private let settingsManager: SettingsManager
    
    // MARK: Outlets
    
    @IBOutlet private var unitFormatSegmentedControl: SegmentedControl?
    @IBOutlet private var latLonFormatSegmentedControl: SegmentedControl?
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified coder.
    required init?(coder: NSCoder) {
        self.settingsManager = SettingsManager.shared
        super.init(coder: coder)
    }
    
    /// Initializes a new instance with the specified coder and settings manager.
    init?(coder: NSCoder, settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        super.init(coder: coder)
    }
    
    // MARK: UIViewController Overrides
    
    /// Initializes the view controller after the view has loaded.
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        unitFormatSegmentedControl?.configure(for: UnitFormat.self)
        latLonFormatSegmentedControl?.configure(for: LatLon.Format.self)
        
        initializeBindings()
        
    }
    
    // MARK: Actions
    
    /// The user changed the unit format setting.
    @IBAction
    private func unitFormatSegmentedControlValueChanged(_ sender: SegmentedControl) {
        settingsManager.unitFormat.value = sender.value(for: UnitFormat.self)
    }
    
    /// The user changed the latitude/longitude format setting.
    @IBAction
    private func latLonFormatSegmentedControlValueChanged(_ sender: SegmentedControl) {
        settingsManager.latLonFormat.value = sender.value(for: LatLon.Format.self)
    }
    
    /// The user pressed the Reset All Settings button.
    @IBAction
    private func resetButtonPressed(_ sender: UIButton) {
        
        let settingsManager = self.settingsManager
        
        let controller = UIAlertController(title: LocalizableString(.settingsResetAlertTitle),
                                           message: LocalizableString(.settingsResetAlertMessage),
                                           preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: LocalizableString(.genericReset),
                                           style: .destructive,
                                           handler: { _ in settingsManager.resetAllSettings() }))
        controller.addAction(UIAlertAction(title: LocalizableString(.genericCancel),
                                           style: .cancel,
                                           handler: nil))
        
        controller.loadViewIfNeeded()
        controller.view.tintColor = UIColor(application: .tint)
        
        present(controller, animated: true, completion: nil)
        
    }
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
        
        // Update the unit format setting
        settingsManager.unitFormat.producer.take(duringLifetimeOf: self).startWithValues { [unowned self] unitFormat in
            self.unitFormatSegmentedControl?.setValue(unitFormat, for: UnitFormat.self)
        }
        
        // Update the lat/lon format setting
        settingsManager.latLonFormat.producer.take(duringLifetimeOf: self).startWithValues { [unowned self] latLonFormat in
            self.latLonFormatSegmentedControl?.setValue(latLonFormat, for: LatLon.Format.self)
        }
        
    }
    
}
