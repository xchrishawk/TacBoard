//
//  ModuleListViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/7/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift
import UIKit

// MARK: - ModuleListViewController

/// `UITableViewController` subclass for enabling or disabling a list of modules.
class ModuleListViewController<ModuleType>: TableViewController where ModuleType: Module {

    // MARK: Fields
    
    private let property: MutableProperty<Set<ModuleType>>
    
    @IBOutlet private var toggleEnablementBarButtonItem: UIBarButtonItem?
    
    // MARK: Initialization
    
    /// Initializer not available.
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalNotAvailable() }

    /// Initializes a new instance with the specified coder and property.
    init?(coder: NSCoder, property: MutableProperty<Set<ModuleType>>) {
        self.property = property
        super.init(coder: coder)
    }
    
    // MARK: UIViewController Overrides
    
    /// Initializes the view controller after the view has loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeBindings()
    }
    
    /// The trait collection changed.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    
    /// Returns the number of rows to display in the specified section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ModuleType.all.count
    }
    
    /// Returns a cell for the row at the specified index path.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EnableModuleCell", for: indexPath) as! HomeTableViewCell
        let module = self.module(at: indexPath)
        cell.configure(for: module, isEnabled: property.value.contains(module))
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    /// The user selected the specified cell.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        property.value.toggle(module(at: indexPath))
    }
    
    // MARK: Actions
    
    /// The user pressed the toggle enablement button.
    @IBAction
    private func toggleEnablementBarButtonItemPressed(_ sender: UIBarButtonItem) {
        if isAllSelected {
            property.value.removeAll()
        } else {
            property.value = Set(ModuleType.all)
        }
    }
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
        
        // When enablements change...
        property.producer.take(duringLifetimeOf: self).startWithValues { [unowned self] _ in
            
            // Reload the table view
            self.tableView.reloadData()
            
            // Update the toggle button title, if needed
            self.toggleEnablementBarButtonItem?.title = {
                if self.isAllSelected {
                    return LocalizableString(.genericSelectNone)
                } else {
                    return LocalizableString(.genericSelectAll)
                }
            }()
            
        }
        
    }
    
    /// Returns the module for the cell at the specified index path.
    private func module(at indexPath: IndexPath) -> ModuleType {
        return ModuleType.all[indexPath.row]
    }
    
    /// Returns `true` if all modules are selected.
    private var isAllSelected: Bool {
        return (property.value == Set(ModuleType.all))
    }
    
}

// MARK: - AircraftModuleListViewController

/// Concrete subclass of `ModuleListViewController` for the `AircraftModule` type.
class AircraftModuleListViewController: ModuleListViewController<AircraftModule> { }

// MARK: - TerrainModuleListViewController

/// Concrete subclass of `HomeEnableTerrainViewController` for the `TerrainModule` type.
class TerrainModuleListViewController: ModuleListViewController<TerrainModule> { }
