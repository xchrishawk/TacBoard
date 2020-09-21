//
//  HomeViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift
import UIKit

/// Main view controller for the home page.
class HomeViewController: TableViewController {
    
    // MARK: Types
    
    /// Enumeration of the available sections.
    private enum Section: Int, CaseIterable {
        case menu
        case enabledAircraftModules
        case enabledTerrainModules
    }
    
    /// Enumeration of the available menu items.
    private enum MenuItem: Int, CaseIterable {
        case title
        case about
        case settings
        case help
    }
    
    // MARK: Fields
    
    private let settingsManager: SettingsManager
    private let versionManager: VersionManager
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified coder.
    required init?(coder: NSCoder) {
        self.settingsManager = SettingsManager.shared
        self.versionManager = VersionManager.shared
        super.init(coder: coder)
    }
    
    /// Initializes a new instance with the specified coder and managers.
    init?(coder: NSCoder, settingsManager: SettingsManager, versionManager: VersionManager) {
        self.settingsManager = settingsManager
        self.versionManager = versionManager
        super.init(coder: coder)
    }
    
    // MARK: UIViewController Overrides
    
    /// Initializes the view controller after the view loads.
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeBindings()
    }
    
    /// The trait collection changed.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tableView.reloadData()
    }
    
    /// Prepares for the specified segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
         
        case "ShowHelp":
            guard let controller = segue.destination as? HomeHelpViewController else { fatalInvalidSegue() }
            controller.initialAnchor = sender as? String
            
        default:
            break
            
        }
    }
    
    // MARK: UITableViewDataSource
    
    /// Returns the number of sections to display.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    /// Returns the title for the section at the specified index.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch self.section(for: section) {
        case .menu:
            return nil
        case .enabledAircraftModules:
            return LocalizableString(.homeEnabledAircraftModulesSectionTitle)
        case .enabledTerrainModules:
            return LocalizableString(.homeEnabledTerrainModulesSectionTitle)
        }
    }
    
    /// Returns the number of rows to display in the specified section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.section(for: section) {
        case .menu:
            return MenuItem.allCases.count
        case .enabledAircraftModules:
            return AircraftModule.primaryModules.count + 1 // for all modules
        case .enabledTerrainModules:
            return TerrainModule.primaryModules.count + 1 // for all modules
        }
    }
    
    /// Returns a cell for the row at the specified index path.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch section(for: indexPath.section) {
            
        case .menu:
            return self.tableView(tableView, cellForMenuItem: menuItem(at: indexPath), at: indexPath)
            
        case .enabledAircraftModules:
            if let aircraftModule = self.aircraftModule(at: indexPath) {
                return self.tableView(tableView, cellForModule: aircraftModule, property: settingsManager.enabledAircraftModules, at: indexPath)
            } else {
                return self.tableView(tableView, showAllCellForProperty: settingsManager.enabledAircraftModules, at: indexPath)
            }
            
        case .enabledTerrainModules:
            if let terrainModule = self.terrainModule(at: indexPath) {
                return self.tableView(tableView, cellForModule: terrainModule, property: settingsManager.enabledTerrainModules, at: indexPath)
            } else {
                return self.tableView(tableView, showAllCellForProperty: settingsManager.enabledTerrainModules, at: indexPath)
            }
            
        }
    }
    
    // MARK: UITableViewDelegate
    
    /// The user selected the cell at the specified index path.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch section(for: indexPath.section) {
            
        case .menu:
            switch menuItem(at: indexPath) {
                
            case .title:
                break
                
            case .about:
                performSegue(withIdentifier: "ShowAbout", sender: nil)
             
            case .settings:
                performSegue(withIdentifier: "ShowSettings", sender: nil)
                
            case .help:
                // Default to the version history if the user hasn't viewed it for this release
                performSegue(withIdentifier: "ShowHelp", sender: (versionManager.userHasViewedReleaseNotesForThisVersion ? nil : "VersionHistory"))
                versionManager.userHasViewedReleaseNotesForThisVersion = true
                tableView.reloadData() // trying to reload only the relevant cell results in the help icon being mis-sized
                    
            }
            
        case .enabledAircraftModules:
            if let aircraftModule = self.aircraftModule(at: indexPath) {
                
                // Cell represents an aircraft module
                settingsManager.enabledAircraftModules.value.toggle(aircraftModule)
                
            } else {
                
                // Cell is the "see all" cell
                performSegue(withIdentifier: "ShowAircraftModuleSelector", sender: nil)
                
            }
            
        case .enabledTerrainModules:
            if let terrainModule = self.terrainModule(at: indexPath) {
                
                // Cell represents a terrain module
                settingsManager.enabledTerrainModules.value.toggle(terrainModule)
                
            } else {
                
                // Cell is the "see all" cell
                performSegue(withIdentifier: "ShowTerrainModuleSelector", sender: nil)
                
            }
            
        }
        
    }
    
    // MARK: Segue Actions
    
    /// Creates a `ModuleListViewController` instance to select the enabled aircraft modules.
    @IBSegueAction
    private func createEnableAircraftModuleViewController(_ coder: NSCoder) -> UIViewController? {
        return AircraftModuleListViewController(coder: coder, property: settingsManager.enabledAircraftModules)
    }
    
    /// Creates a `ModuleListViewController` instance to select the enabled terrain modules.
    @IBSegueAction
    private func createEnableTerrainModuleViewController(_ coder: NSCoder) -> UIViewController? {
        return TerrainModuleListViewController(coder: coder, property: settingsManager.enabledTerrainModules)
    }
    
    // MARK: Cell Generation
    
    /// Returns a cell for the specified menu item.
    private func tableView(_ tableView: UITableView, cellForMenuItem item: MenuItem, at indexPath: IndexPath) -> UITableViewCell {
        
        // Title is handled specially
        guard item != .title else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! HomeTitleTableViewCell
            
            cell.titleLabel?.text = AppInfo.shared.name
            cell.versionLabel?.text = "\(LocalizableString(.genericVersion)) \(AppInfo.shared.version)"
            
            return cell
            
        }
        
        // All others use the menu cell type
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as! HomeTableViewCell
        
        cell.titleLabel?.safeIsHidden = false
        cell.iconImageView?.safeIsHidden = false
        
        switch item {
            
        case .title:
            fatalError() // not possible - see above
         
        case .about:
            cell.titleLabel?.text = LocalizableString(.homeAboutPage)
            cell.iconImageView?.image = UIImage(systemName: "airplane")
            
        case .settings:
            cell.titleLabel?.text = LocalizableString(.homeSettingsPage)
            cell.iconImageView?.image = UIImage(systemName: "wrench.fill")
            
        case .help:
            cell.titleLabel?.text = LocalizableString(.homeHelpPage)
            cell.iconImageView?.image = UIImage(systemName: "questionmark.circle.fill")
            if !versionManager.userHasViewedReleaseNotesForThisVersion {
                cell.auxiliaryDataStackView?.safeIsHidden = false
                cell.auxiliaryDataIconImageView?.image = UIImage(systemName: "info.circle.fill")
                cell.auxiliaryDataIconImageView?.safeIsHidden = false
                cell.auxiliaryDataLabel?.text = LocalizableString(.homeAppUpdated)
                cell.auxiliaryDataLabel?.safeIsHidden = false
            }
            
        }
        
        return cell
        
    }
    
    /// Returns an enablement cell for the specified module at the specified index path.
    private func tableView<ModuleType>(_ tableView: UITableView, cellForModule module: ModuleType, property: MutableProperty<Set<ModuleType>>, at indexPath: IndexPath) -> UITableViewCell where ModuleType: Module {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EnableModuleCell", for: indexPath) as! HomeTableViewCell
        cell.configure(for: module, isEnabled: property.value.contains(module))
        return cell
    }
    
    // Returns an "All Modules" cell for the specified property at the specified index path.
    private func tableView<ModuleType>(_ tableView: UITableView, showAllCellForProperty property: MutableProperty<Set<ModuleType>>, at indexPath: IndexPath) -> UITableViewCell where ModuleType: Module {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as! HomeTableViewCell
        
        cell.titleLabel?.text = LocalizableString(.homeAllModulesPage)
        cell.titleLabel?.safeIsHidden = false
        
        cell.subtitleLabel?.text = "\(property.value.count) \(LocalizableString(.genericSelected))"
        cell.subtitleLabel?.safeIsHidden = false
        
        cell.iconImageView?.image = UIImage(systemName: "ellipsis")
        cell.iconImageView?.safeIsHidden = false
        
        return cell
        
    }
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
     
        // Reload the aircraft section when the enabled aircraft change
        settingsManager.enabledAircraftModules.producer.take(duringLifetimeOf: self).startWithValues { [unowned self] _ in
            self.tableView.reloadData()
        }
        
        // Reload the terrains section when the enabled terrains change
        settingsManager.enabledTerrainModules.producer.take(duringLifetimeOf: self).startWithValues { [unowned self] _ in
            self.tableView.reloadData()
        }
        
    }
    
    /// Returns the `Section` for the specified section index.
    private func section(for index: Int) -> Section {
        guard let section = Section(rawValue: index) else { fatalInvalidIndexPath() }
        return section
    }
    
    /// Returns the `MenuItem` at the specified index path.
    private func menuItem(at indexPath: IndexPath) -> MenuItem {
        guard
            section(for: indexPath.section) == .menu,
            let item = MenuItem(rawValue: indexPath.row)
            else { fatalInvalidIndexPath() }
        return item
    }
    
    /// Returns the `AircraftModule` for the specified index path.
    private func aircraftModule(at indexPath: IndexPath) -> AircraftModule? {
        guard section(for: indexPath.section) == .enabledAircraftModules else { fatalInvalidIndexPath() }
        guard indexPath.row < AircraftModule.primaryModules.count else { return nil }
        return AircraftModule.primaryModules[indexPath.row]
    }
    
    /// Returns the `TerrainModule` for the specified index path.
    private func terrainModule(at indexPath: IndexPath) -> TerrainModule? {
        guard section(for: indexPath.section) == .enabledTerrainModules else { fatalInvalidIndexPath() }
        guard indexPath.row < TerrainModule.primaryModules.count else { return nil }
        return TerrainModule.primaryModules[indexPath.row]
    }

}
