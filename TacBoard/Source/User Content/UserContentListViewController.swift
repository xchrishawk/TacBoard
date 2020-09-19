//
//  UserContentListViewController.swift
//  TacBoard
//
//  Created by Chris Vig on 9/19/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// View controller for displaying the currently active user content.
class UserContentListViewController: UITableViewController {
    
    // MARK: Types
    
    /// Enumeration of sections displayed by this view controller.
    private enum Section {
     
        /// The section for displaying checklists.
        case checklists
        
        /// The section for display invalid files.
        case invalids
        
    }
    
    // MARK: Fields
    
    private let userContentManager = UserContentManager.shared
    private var sections: [Section] = []
    
    // MARK: UIViewController Overrides
    
    /// Initializes the view controller after the view loads.
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        initializeBindings()
        refreshData()
        
    }
    
    // MARK: Outlets
    
    @IBOutlet private var noUserContentView: UIView?
    
    // MARK: UITableViewDataSource

    /// Returns the number of sections to display.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    /// Returns the title for the header of the specified section index.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch self.section(at: section) {
        case .checklists:
            return LocalizableString(.userContentListChecklistsSectionTitle)
        case .invalids:
            return LocalizableString(.userContentListInvalidsSectionTitle)
        }
    }
    
    /// Returns the title for the footer of the specified section index.
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch self.section(at: section) {
        case .invalids:
            return LocalizableString(.userContentListInvalidsSectionFooter)
        default:
            return nil
        }
    }
    
    /// Returns the number of rows in the specified section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.section(at: section) {
        case .checklists:
            return userContentManager.checklists.value.count
        case .invalids:
            return userContentManager.invalids.value.count
        }
    }
    
    /// Returns a cell for the row at the specified index path.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch section(at: indexPath.section) {
        case .checklists:
            return self.tableView(tableView, cellForChecklist: checklist(at: indexPath), at: indexPath)
        case .invalids:
            return self.tableView(tableView, cellForInvalid: invalid(at: indexPath), at: indexPath)
        }
    }
    
    // MARK: UITableViewDelegate
    
    /// Returns the swipe actions to display for the row at the specified index path.
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        /// Returns swipe actions with the specified closure.
        func actions(deleteURL url: URL) -> UISwipeActionsConfiguration {
            
            // Handler closure for the action
            let handler: UIContextualAction.Handler = { [weak self] (_, _, completion) in
                
                guard let self = self else {
                    completion(false)
                    return
                }
                
                let alert = UIAlertController(title: LocalizableString(.userContentDeleteConfirmationTitle),
                                              message: LocalizableString(.userContentDeleteConfirmationMessage),
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: LocalizableString(.genericCancel),
                                              style: .cancel,
                                              handler: { _ in completion(false) }))
                alert.addAction(UIAlertAction(title: LocalizableString(.genericDelete),
                                              style: .destructive,
                                              handler: { _ in
                                                _ = try? FileManager.default.removeItem(at: url)
                                                completion(true)
                                              }))
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
            // The action itself
            let action = UIContextualAction(style: .destructive,
                                            title: LocalizableString(.genericDelete),
                                            handler: handler)
            
            // The overall configuration
            return UISwipeActionsConfiguration(actions: [action])
            
        }

        // Display a confirmation box to delete the relevant URL
        switch section(at: indexPath.section) {
        case .checklists:
            let checklist = self.checklist(at: indexPath)
            return actions(deleteURL: checklist.url)
        case .invalids:
            let invalid = self.invalid(at: indexPath)
            return actions(deleteURL: invalid.url)
        }
        
    }
    
    /// The user tapped the accessory button for the cell at the specified index path.
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        switch section(at: indexPath.section) {
        case .invalids:
            displayError(for: invalid(at: indexPath))
        default:
            break
        }
    }
    
    // MARK: Cell Generation
    
    /// Returns a cell for the `UserChecklistDataIndex` at the specified index path.
    private func tableView(_ tableView: UITableView, cellForChecklist checklist: UserChecklistDataIndex, at indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistCell", for: indexPath) as! UserContentListTableViewCell

        cell.fileNameLabel?.text = checklist.url.lastPathComponent
        cell.fileSizeLabel?.text = fileSizeString(for: checklist.size)

        return cell
        
    }
    
    /// Returns a cell for the `InvalidUserContent` at the specified index path.
    private func tableView(_ tableView: UITableView, cellForInvalid invalid: InvalidUserContent, at indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "InvalidCell", for: indexPath) as! UserContentListTableViewCell
        
        cell.fileNameLabel?.text = invalid.url.lastPathComponent
        cell.fileSizeLabel?.text = fileSizeString(for: invalid.size)
        
        return cell
        
    }
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
        
        // Refresh the table view when the user content manager updates
        userContentManager.updated.take(duringLifetimeOf: self).startWithValues { [unowned self] in
            self.refreshData()
        }
        
    }
    
    /// Refreshes the currently displayed data.
    private func refreshData() {
     
        var sections: [Section] = []
        if !userContentManager.checklists.value.isEmpty { sections.append(.checklists) }
        if !userContentManager.invalids.value.isEmpty { sections.append(.invalids) }
        self.sections = sections
        
        tableView.reloadData()
        
        isNoUserContentViewDisplayed = sections.isEmpty
        
    }
    
    /// Displays the error message for the specified invalid content.
    private func displayError(for invalid: InvalidUserContent) {
        
        let alert = UIAlertController(title: LocalizableString(.userContentListInvalidsErrorMessageTitle), message: invalid.error.localizedDescription, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizableString(.genericOK), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete File", style: .destructive) { _ in
            _ = try? FileManager.default.removeItem(at: invalid.url)
        })
        
        present(alert, animated: true, completion: nil)
        
    }
    
    /// Returns the `Section` at the specified section index.
    private func section(at index: Int) -> Section {
        return sections[index]
    }
    
    /// Returns the `UserChecklistDataIndex` at the specified index path.
    private func checklist(at indexPath: IndexPath) -> UserChecklistDataIndex {
        guard sections[indexPath.section] == .checklists else { fatalInvalidIndexPath() }
        return userContentManager.checklists.value[indexPath.row]
    }
    
    /// Returns the `InvalidUserContent` at the specified index path.
    private func invalid(at indexPath: IndexPath) -> InvalidUserContent {
        guard sections[indexPath.section] == .invalids else { fatalInvalidSegue() }
        return userContentManager.invalids.value[indexPath.row]
    }
    
    /// Returns a file size string for the specified file size.
    private func fileSizeString(for size: Int64?) -> String {
        
        struct Local {
            static let byteCountFormatter: ByteCountFormatter = {
                let bcf = ByteCountFormatter()
                bcf.allowedUnits = [.useAll]
                bcf.countStyle = .file
                return bcf
            }()
        }
        
        guard let size = size else { return LocalizableString(.genericNA) }
        return Local.byteCountFormatter.string(fromByteCount: size)
        
    }
    
    /// If set to `true`, the `noUserContentView` view will be displayed.
    private var isNoUserContentViewDisplayed: Bool = false {
        didSet {
         
            guard
                isNoUserContentViewDisplayed != oldValue,
                let noUserContentView = noUserContentView
                else { return }
            
            if isNoUserContentViewDisplayed {
                
                // Add the view
                view.addSubview(noUserContentView)
                noUserContentView.translatesAutoresizingMaskIntoConstraints = false
                noUserContentView.centerXAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerXAnchor).isActive = true
                noUserContentView.centerYAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerYAnchor).isActive = true
                noUserContentView.widthAnchor.constraint(lessThanOrEqualTo: tableView.safeAreaLayoutGuide.widthAnchor, constant: -20.0).isActive = true
                noUserContentView.sizeToFit()
                
            } else {
                
                // Remove the view
                noUserContentView.removeFromSuperview()
                
            }
            
        }
    }
    
}

/// Custom `UITableViewCell` for displaying user content.
class UserContentListTableViewCell: SelectableHighlightableTableViewCell {
 
    // MARK: Outlets
    
    /// The label to display the file name of the file.
    @IBOutlet var fileNameLabel: UILabel?
    
    /// The label to display the size of the file.
    @IBOutlet var fileSizeLabel: UILabel?
    
    // MARK: UITableViewCell Overrides
    
    /// Initializes the cell after it is deserialized from the nib.
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    /// Initializes the cell when it is about to be reused.
    override func prepareForReuse() {
        super.prepareForReuse()
        initialize()
    }
    
    // MARK: Private Utility
    
    /// Initializes the cell.
    private func initialize() {
        fileNameLabel?.text = nil
        fileSizeLabel?.text = nil
    }
    
}
