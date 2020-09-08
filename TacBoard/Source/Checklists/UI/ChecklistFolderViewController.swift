//
//  ChecklistFolderViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import UIKit

/// Concrete implementation of `FolderVieController` for checklists.
class ChecklistFolderViewController: FolderViewController<ChecklistViewModel> {
    
    // MARK: Outlets
    
    @IBOutlet private var resetAllChecklistsBarButtonItem: UIBarButtonItem?
    
    // MARK: FolderViewController Overrides
    
    /// Returns the title for the folders section.
    override var folderSectionTitle: String {
        return LocalizableString(.checklistFoldersSectionTitle)
    }
    
    /// Returns the title for the items section.
    override var itemSectionTitle: String {
        return LocalizableString(.checklistProceduresSectionTitle)
    }
    
    /// Returns a `ChecklistFolderViewController` for the specified folder.
    override func folderViewController(coder: NSCoder, viewModel: ChecklistViewModel, folder: Folder<ChecklistProcedure>) -> UIViewController? {
        return ChecklistFolderViewController(coder: coder, viewModel: viewModel, folder: folder)
    }
    
    /// Returns a `UITableViewCell` for the specified folder.
    override func tableView(_ tableView: UITableView, cellForFolder folder: Folder<ChecklistProcedure>, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath) as! FolderTableViewCell
        cell.configure(for: folder)
        return cell
    }
    
    /// Returns a `UITableViewCell` for the specified procedure.
    override func tableView(_ tableView: UITableView, cellForItem item: ChecklistProcedure, at indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProcedureCell", for: indexPath) as! ChecklistProcedureTableViewCell
        
        // Basic info
        cell.titleLabel?.text = item.title
        cell.accessoryType = (traitCollection.horizontalSizeClass == .compact ? .disclosureIndicator : .none)
        
        // Auto-update visibility of isComplete image view
        if let isCompleteImageView = cell.isCompleteImageView {
            isCompleteImageView.reactive.alpha <~ item.isComplete.producer.take(until: cell.reactive.prepareForReuse).map { ($0 ? 1.0 : 0.0) }
        }
        
        return cell
        
    }
    
    // MARK: Actions
    
    /// The user pressed the "reset all checklists" bar button item.
    @IBAction
    private func resetAllChecklistsBarButtonItemPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: LocalizableString(.checklistResetAllAlertTitle),
                                      message: String(format: LocalizableString(.checklistResetAllAlertFolderMessage), folder.title),
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizableString(.genericOK), style: .destructive, handler: { _ in self.folder.setIsComplete(false) }))
        alert.addAction(UIAlertAction(title: LocalizableString(.genericCancel), style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
}
