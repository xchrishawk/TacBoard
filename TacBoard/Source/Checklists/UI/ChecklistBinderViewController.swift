//
//  ChecklistBinderViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift
import UIKit

/// Concrete implementation of `BinderViewController` for checklists.
class ChecklistBinderViewController: BinderViewController<ChecklistViewModel> {
    
    // MARK: Outlets
    
    @IBOutlet private var resetAllChecklistsBarButtonItem: UIBarButtonItem?
    
    // MARK: BinderViewController Overrides
    
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
    
    /// Returns a `String` explaining why there are no binders available.
    override func noItemsAvailableExplanation(viewModel: ChecklistViewModel) -> String {
        if viewModel.enabledAircraftModules.value.isEmpty {
            return LocalizableString(.checklistBinderEnableAircraftModule)
        } else {
            return LocalizableString(.checklistBinderNoMatches)
        }
    }
    
    // MARK: Actions
    
    /// The user pressed the "reset all checklists" bar button item.
    @IBAction
    private func resetAllChecklistsBarButtonItemPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: LocalizableString(.checklistResetAllAlertTitle),
                                      message: LocalizableString(.checklistResetAllAlertBinderMessage),
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizableString(.genericOK), style: .destructive, handler: { _ in
            for binder in self.viewModel.allBinders.value {
                for folder in binder.folders {
                    folder.setIsComplete(false)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: LocalizableString(.genericCancel), style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
}
