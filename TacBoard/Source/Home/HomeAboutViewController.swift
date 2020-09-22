//
//  HomeAboutViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/12/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift
import UIKit

// MARK: - HomeAboutViewController

/// View controller for the About page.
class HomeAboutViewController: TableViewController {
    
    // MARK: Fields
    
    private let airportViewModel = AirportViewModel.shared
    private let appInfo = AppInfo.shared
    private let checklistViewModel = ChecklistViewModel.shared
    private let contentManager = ContentManager.shared
    private let referenceViewModel = ReferenceViewModel.shared
    private let userContentManager = UserContentManager.shared

    // MARK: Types

    /// Enumeration of the available sections.
    private enum Section: Int, CaseIterable {
        case appInfo
        case dataInfo
        #if DEBUG
        case debug
        #endif
    }
    
    /// Enumeration of items in the `.appInfo` section.
    private enum AppInfoItem: Int, CaseIterable {
        case name
        case version
        case build
        case type
        case date
        case commit
    }
    
    /// Enumeration of items in the `.dataInfo` section.
    private enum DataInfoItem: Int, CaseIterable {
        case airports
        case checklists
        case reference
        case userContent
        case checkForUpdatedData
    }
    
    #if DEBUG
    
    /// Enumeration of items in the `.debug` section.
    private enum DebugItem: Int, CaseIterable {
        case useFallbackData
        case useLocalData
        case useStagingData
        case useProductionData
    }
    
    #endif
    
    // MARK: Outlets
    
    @IBOutlet private var checkingForUpdatedDataView: UIView?
    
    // MARK: UIViewController Overrides
    
    /// Initializes the view controller after the view has loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeBindings()
        checkingForUpdatedDataView?.layer.cornerRadius = 10.0
    }
    
    // MARK: UITableViewDataSource
    
    /// Returns the number of sections to display.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    /// Returns the title for the section at the specified index.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch self.section(at: section) {
        case .appInfo:
            return LocalizableString(.aboutAppInfoSection)
        case .dataInfo:
            return LocalizableString(.aboutDataInfoSection)
        #if DEBUG
        case .debug:
            return LocalizableString(.aboutDebugSection)
        #endif
        }
    }
    
    /// Returns the number of rows to display in the cell with the specified index.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.section(at: section) {
        case .appInfo:
            return AppInfoItem.allCases.count
        case .dataInfo:
            return DataInfoItem.allCases.count
        #if DEBUG
        case .debug:
            return DebugItem.allCases.count
        #endif
        }
    }
    
    /// Returns a cell for the row at the specified index path.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch section(at: indexPath.section) {
        case .appInfo:
            return self.tableView(tableView, cellForAppInfoItem: appInfoItem(at: indexPath), at: indexPath)
        case .dataInfo:
            return self.tableView(tableView, cellForDataInfoItem: dataInfoItem(at: indexPath), at: indexPath)
        #if DEBUG
        case .debug:
            return self.tableView(tableView, cellForDebugItem: debugItem(at: indexPath), at: indexPath)
        #endif
        }
    }
    
    // MARK: UITableViewDelegate
    
    /// Returns the height for the row at the specified index path.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.defaultRowHeight
    }
    
    /// The user selected the cell at the specified index path.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch section(at: indexPath.section) {
        
        case .dataInfo:
            switch dataInfoItem(at: indexPath) {
            
            case .userContent:
                performSegue(withIdentifier: "ShowUserContentList", sender: nil)
                
            default:
                break
                
            }
        
        default:
            break
        
        }
    }
    
    // MARK: Cell Generation
    
    /// Creates a cell for the specified `AppInfoItem` at the specified `IndexPath`.
    private func tableView(_ tableView: UITableView, cellForAppInfoItem appInfoItem: AppInfoItem, at indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoItem", for: indexPath) as! HomeAboutInfoItemTableViewCell
            
        switch appInfoItem {
            
        case .name:
            cell.titleLabel?.text = LocalizableString(.aboutAppInfoItemName)
            cell.valueLabel?.text = appInfo.name
            
        case .version:
            cell.titleLabel?.text = LocalizableString(.aboutAppInfoItemVersion)
            cell.valueLabel?.text = appInfo.version
            
        case .build:
            cell.titleLabel?.text = LocalizableString(.aboutAppInfoItemBuild)
            cell.valueLabel?.text = appInfo.build
            
        case .type:
            cell.titleLabel?.text = LocalizableString(.aboutAppInfoItemType)
            #if DEBUG
            cell.valueLabel?.text = LocalizableString(.genericDebug)
            #else
            cell.valueLabel?.text = LocalizableString(.genericRelease)
            #endif
            
        case .date:
            cell.titleLabel?.text = LocalizableString(.aboutAppInfoItemDate)
            cell.valueLabel?.text = {

                var result = ""
                let formatter = DateFormatter()
                
                formatter.timeStyle = .medium
                formatter.dateStyle = .none
                result += "\(formatter.string(from: appInfo.date))"
                
                formatter.timeStyle = .none
                formatter.dateStyle = .long
                result += "\n\(formatter.string(from: appInfo.date))"
                
                return result
                
            }()
            
        case .commit:
            cell.titleLabel?.text = LocalizableString(.aboutAppInfoItemCommit)
            cell.valueLabel?.text = {
                let commit = appInfo.commit
                if let index = commit.index(commit.startIndex, offsetBy: 10, limitedBy: commit.endIndex) {
                    return String(commit[..<index]) // man swift strings are awful
                } else {
                    return commit
                }
            }()
        }
        
        return cell
        
    }
    
    /// Creates a cell for the specified `DataInfoItem` at the specified `IndexPath`.
    private func tableView(_ tableView: UITableView, cellForDataInfoItem dataInfoItem: DataInfoItem, at indexPath: IndexPath) -> UITableViewCell {
        
        // The "check for updated data" cell is handled specially
        guard dataInfoItem != .checkForUpdatedData else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommandItem", for: indexPath) as! HomeAboutCommandTableViewCell
            
            cell.button?.setTitle(LocalizableString(.aboutDataInfoCheckForUpdatedData), for: .normal)
            cell.button?.touchUpInside = { [weak self, weak cell] in
                
                // Tell all of the data consumers to reload their data
                self?.contentManager.reloadContentNow()
                self?.userContentManager.reloadContentNow()

                // Briefly display the checking view
                self?.isCheckingForUpdatedDataViewDisplayed = true
                cell?.button?.isEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) { [weak self, weak cell] in
                    self?.isCheckingForUpdatedDataViewDisplayed = false
                    cell?.button?.isEnabled = true
                }

            }
            
            return cell
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoItem", for: indexPath) as! HomeAboutInfoItemTableViewCell
        
        func value<Object>(for index: DataIndex<Object>, source: ContentSource) -> String {
            return "\(index.description)\n\(source.description) \(LocalizableString(.genericVersion)) \(index.version)"
        }
        
        switch dataInfoItem {
            
        case .airports:
            cell.titleLabel?.text = LocalizableString(.aboutDataInfoItemAirports)
            cell.valueLabel?.text = value(for: airportViewModel.primaryDataIndex.value,
                                          source: airportViewModel.primaryDataIndexSource.value)
            cell.accessoryType = .none
            
        case .checklists:
            cell.titleLabel?.text = LocalizableString(.aboutDataInfoItemChecklists)
            cell.valueLabel?.text = value(for: checklistViewModel.primaryDataIndex.value,
                                          source: checklistViewModel.primaryDataIndexSource.value)
            
        case .reference:
            cell.titleLabel?.text = LocalizableString(.aboutDataInfoItemReference)
            cell.valueLabel?.text = value(for: referenceViewModel.primaryDataIndex.value,
                                          source: referenceViewModel.primaryDataIndexSource.value)
         
        case .userContent:
            let count = userContentManager.count
            cell.titleLabel?.text = LocalizableString(.aboutDataInfoItemUserContentList)
            cell.valueLabel?.text = "\(count) \(LocalizableString(count == 1 ? .genericFile : .genericFiles))"
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .blue
            
        case .checkForUpdatedData:
            fatalError("Not possible - see above")
            
        }
        
        return cell
        
    }
    
    #if DEBUG
    
    /// Creates a cell for the specified `DebugItem` at the specified `IndexPath`.
    private func tableView(_ tableView: UITableView, cellForDebugItem debugItem: DebugItem, at indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommandItem", for: indexPath) as! HomeAboutCommandTableViewCell
        
        func closure(for source: ContentSource) -> () -> Void {
            return { [weak self] in self?.contentManager.source.value = source }
        }
        
        switch debugItem {
         
        case .useFallbackData:
            cell.button?.setTitle(LocalizableString(.aboutDebugUseFallbackData), for: .normal)
            cell.button?.touchUpInside = closure(for: .fallback)
            
        case .useLocalData:
            cell.button?.setTitle(LocalizableString(.aboutDebugUseLocalData), for: .normal)
            cell.button?.touchUpInside = closure(for: .local)
            
        case .useStagingData:
            cell.button?.setTitle(LocalizableString(.aboutDebugUseStagingData), for: .normal)
            cell.button?.touchUpInside = closure(for: .staging)
            
        case .useProductionData:
            cell.button?.setTitle(LocalizableString(.aboutDebugUseProductionData), for: .normal)
            cell.button?.touchUpInside = closure(for: .production)
            
        }
        
        return cell
        
    }
    
    #endif
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
        
        // Reload the table view whenever any of the data indices change
        let updateProducer = SignalProducer.combineLatest(airportViewModel.primaryDataIndex.producer,
                                                          airportViewModel.primaryDataIndexSource.producer,
                                                          checklistViewModel.primaryDataIndex.producer,
                                                          checklistViewModel.primaryDataIndexSource.producer,
                                                          referenceViewModel.primaryDataIndex.producer,
                                                          referenceViewModel.primaryDataIndexSource.producer,
                                                          userContentManager.updated)
        updateProducer.throttle(0.25, on: QueueScheduler.main).take(duringLifetimeOf: self).startWithValues { [unowned self] _ in
            self.tableView.reloadData()
        }
        
    }
    
    /// Returns the `Section` at the specified section index.
    private func section(at index: Int) -> Section {
        guard let section = Section(rawValue: index) else { fatalInvalidIndexPath() }
        return section
    }
    
    /// Returns the `AppInfoItem` at the specified index path.
    private func appInfoItem(at indexPath: IndexPath) -> AppInfoItem {
        guard
            section(at: indexPath.section) == .appInfo,
            let appInfoItem = AppInfoItem(rawValue: indexPath.row)
            else { fatalInvalidIndexPath() }
        return appInfoItem
    }
    
    /// Returns the `DataInfoItem` at the specified index path.
    private func dataInfoItem(at indexPath: IndexPath) -> DataInfoItem {
        guard
            section(at: indexPath.section) == .dataInfo,
            let dataInfoItem = DataInfoItem(rawValue: indexPath.row)
            else { fatalInvalidIndexPath() }
        return dataInfoItem
    }
    
    #if DEBUG
    
    /// Returns the `DebugItem` at the specified index path.
    private func debugItem(at indexPath: IndexPath) -> DebugItem {
        guard
            section(at: indexPath.section) == .debug,
            let debugItem = DebugItem(rawValue: indexPath.row)
            else { fatalInvalidIndexPath() }
        return debugItem
    }
    
    #endif
    
    /// If set to `true`, the "Checking For Updated Data..." view will be displayed.
    private var isCheckingForUpdatedDataViewDisplayed: Bool = false {
        didSet {
         
            guard
                let checkingForUpdatedDataView = checkingForUpdatedDataView,
                isCheckingForUpdatedDataViewDisplayed != oldValue
                else { return }
            
            if isCheckingForUpdatedDataViewDisplayed {
                
                // Display the view
                view.addSubview(checkingForUpdatedDataView)
                checkingForUpdatedDataView.translatesAutoresizingMaskIntoConstraints = false
                view.safeAreaLayoutGuide.centerXAnchor.constraint(equalTo: checkingForUpdatedDataView.centerXAnchor).isActive = true
                view.safeAreaLayoutGuide.centerYAnchor.constraint(equalTo: checkingForUpdatedDataView.centerYAnchor).isActive = true
                view.safeAreaLayoutGuide.widthAnchor.constraint(greaterThanOrEqualTo: checkingForUpdatedDataView.widthAnchor, multiplier: 1.0, constant: 20.0).isActive = true
                
            } else {
                
                // Remove the view
                checkingForUpdatedDataView.removeFromSuperview()
                
            }
            
        }
    }
    
}

// MARK: - HomeAboutInfoItemTableViewCell

/// `UITableViewCell` subclass for the `HomeAboutViewController` table view controller.
class HomeAboutInfoItemTableViewCell: SelectableHighlightableTableViewCell {

    // MARK: Outlets
    
    /// The label for the item title.
    @IBOutlet var titleLabel: UILabel?
    
    /// The label for the item value.
    @IBOutlet var valueLabel: UILabel?

    // MARK: UITableViewCell Overrides
    
    /// Configures the cell when it is awoken from the nib.
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    /// Configures the cell when it is about to be reused.
    override func prepareForReuse() {
        super.prepareForReuse()
        initialize()
    }
    
    // MARK: Private Utility
    
    /// Initializes the cell to a default state.
    private func initialize() {
        
        accessoryType = .none
        selectionStyle = .none
        
        titleLabel?.text = nil
        valueLabel?.text = nil
        
    }
    
}

// MARK: - HomeAboutCommandTableViewCell

/// `UITableViewCell` subclass containing a button to execute a command.
class HomeAboutCommandTableViewCell: UITableViewCell {

    /// The button to execute the debug command.
    @IBOutlet var button: BlockButton?
    
}
