//
//  ReferenceFolderViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/16/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Concrete implementation of `FolderViewController` for reference documents.
class ReferenceFolderViewController: FolderViewController<ReferenceViewModel> {

    // MARK: FolderViewController Overrides
    
    /// Returns the title for the folders section.
    override var folderSectionTitle: String {
        return LocalizableString(.referenceFoldersSectionTitle)
    }
    
    /// Returns the title for the items section.
    override var itemSectionTitle: String {
        return LocalizableString(.referenceDocumentsSectionTitle)
    }
    
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
    
    /// Returns `UITableViewCell` for the specified reference document.
    override func tableView(_ tableView: UITableView, cellForItem item: ReferenceDocument, at indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath) as! ReferenceDocumentTableViewCell
        
        cell.titleLabel?.text = item.title
        cell.subtitleLabel?.text = item.subtitle
        cell.subtitleLabel?.safeIsHidden = item.subtitle.isNilOrEmpty
        cell.accessoryType = (traitCollection.horizontalSizeClass == .compact ? .disclosureIndicator : .none)
        
        return cell
        
    }
    
}
