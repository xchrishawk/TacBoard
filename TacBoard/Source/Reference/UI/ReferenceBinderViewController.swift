//
//  ReferenceBinderViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/16/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Concrete implementation of `BinderViewController` for reference documents.
class ReferenceBinderViewController: BinderViewController<ReferenceViewModel> {
    
    // MARK: BinderViewController Overrides
    
    /// Returns a `ReferenceFolderViewController` for the specified folder.
    override func folderViewController(coder: NSCoder, viewModel: ReferenceViewModel, folder: Folder<ReferenceDocument>) -> UIViewController? {
        return ReferenceFolderViewController(coder: coder, viewModel: viewModel, folder: folder)
    }
    
    /// Returns a `UITableViewCell` for the specified folder.
    override func tableView(_ tableView: UITableView, cellForFolder folder: Folder<ReferenceDocument>, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath) as! FolderTableViewCell
        cell.configure(for: folder)
        return cell
    }
    
    /// Returns a `String` explaining why there are no binders available.
    override func noItemsAvailableExplanation(viewModel: ReferenceViewModel) -> String {
        return LocalizableString(.referenceBinderNoMatches)
    }

}
