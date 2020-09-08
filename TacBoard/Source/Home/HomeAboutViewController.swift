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
    
    private let appInfo: AppInfo
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified coder.
    required init?(coder: NSCoder) {
        self.appInfo = AppInfo.shared
        super.init(coder: coder)
    }
    
    /// Initializes a new instance with the specified coder and app info.
    init?(coder: NSCoder, appInfo: AppInfo) {
        self.appInfo = appInfo
        super.init(coder: coder)
    }

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
    
    // MARK: UIViewController Overrides
    
    /// Initializes the view controller after the view has loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeBindings()
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
               
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .long
                
                return formatter.string(from: appInfo.date)
                
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoItem", for: indexPath) as! HomeAboutInfoItemTableViewCell
        
        func value<Object>(for index: DataIndex<Object>, source: ContentSource) -> String {
            return "\(index.description)\n\(source.description) \(LocalizableString(.genericVersion)) \(index.version)"
        }
        
        switch dataInfoItem {
            
        case .airports:
            cell.titleLabel?.text = LocalizableString(.aboutDataInfoItemAirports)
            cell.valueLabel?.text = value(for: AirportViewModel.shared.dataIndex.value,
                                          source: AirportViewModel.shared.dataIndexSource.value)
            
        case .checklists:
            cell.titleLabel?.text = LocalizableString(.aboutDataInfoItemChecklists)
            cell.valueLabel?.text = value(for: ChecklistViewModel.shared.dataIndex.value,
                                          source: ChecklistViewModel.shared.dataIndexSource.value)
            
        case .reference:
            cell.titleLabel?.text = LocalizableString(.aboutDataInfoItemReference)
            cell.valueLabel?.text = value(for: ReferenceViewModel.shared.dataIndex.value,
                                          source: ReferenceViewModel.shared.dataIndexSource.value)
            
        }
        
        return cell
        
    }
    
    #if DEBUG
    
    /// Creates a cell for the specified `DebugItem` at the specified `IndexPath`.
    private func tableView(_ tableView: UITableView, cellForDebugItem debugItem: DebugItem, at indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "DebugItem", for: indexPath) as! HomeAboutDebugItemTableViewCell
        
        func closure(for source: ContentSource) -> () -> Void {
            return { ContentManager.shared.source.value = source }
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
        let updateProducer = SignalProducer.combineLatest(AirportViewModel.shared.dataIndex.producer,
                                                          AirportViewModel.shared.dataIndexSource.producer,
                                                          ChecklistViewModel.shared.dataIndex.producer,
                                                          ChecklistViewModel.shared.dataIndexSource.producer,
                                                          ReferenceViewModel.shared.dataIndex.producer,
                                                          ReferenceViewModel.shared.dataIndexSource.producer)
        updateProducer.take(duringLifetimeOf: self).startWithValues { [unowned self] _ in
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
    
}

// MARK: - HomeAboutInfoItemTableViewCell

/// `UITableViewCell` subclass for the `HomeAboutViewController` table view controller.
class HomeAboutInfoItemTableViewCell: UITableViewCell {

    /// The label for the item title.
    @IBOutlet var titleLabel: UILabel?
    
    /// The label for the item value.
    @IBOutlet var valueLabel: UILabel?
    
}

// MARK: - HomeAboutDebugItemTableViewCell

/// `UITableViewCell` subclass containing a button to execute a debug command.
class HomeAboutDebugItemTableViewCell: UITableViewCell {

    /// The button to execute the debug command.
    @IBOutlet var button: BlockButton?
    
}
