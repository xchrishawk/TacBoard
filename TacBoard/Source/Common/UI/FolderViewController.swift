//
//  FolderViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/15/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift
import UIKit

/// Abstract base class for `UITableViewController`s displaying the contents of a folder.
class FolderViewController<ViewModel>: TableViewController where ViewModel: BinderViewModel {
    
    // MARK: Fields
    
    private var deferredTableViewUpdate = false
    
    // MARK: Initialization
    
    /// Initializer not available.
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalNotAvailable() }
    
    /// Initializes a new instance with the specified coder, view model, and folder.
    init?(coder: NSCoder, viewModel: ViewModel, folder: Folder<ViewModel.Item>) {
        self.viewModel = viewModel
        self.folder = folder
        super.init(coder: coder)
    }
    
    // MARK: Properties
    
    /// The view model for this view controller.
    let viewModel: ViewModel
    
    /// The folder which is being displayed.
    let folder: Folder<ViewModel.Item>
    
    // MARK: UIViewController Overrides
    
    /// Sets up the view controller after the view has loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = folder.title
        initializeBindings()
    }
    
    /// Called when the view is about to appear.
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // If we deferred a table view UI update due to the table view not being visible, then do it now
        if deferredTableViewUpdate {
            tableView.reloadData()
            deferredTableViewUpdate = false
        }
        
    }
    
    /// The active trait collection changed.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tableView.reloadData() // to add or remove chevrons as needed
    }
    
    // MARK: UITableViewDataSource
    
    /// Returns the number of sections to display.
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        var sections = 0
        
        if isFolderSectionDisplayed { sections += 1 }
        if isItemSectionDisplayed { sections += 1 }
        
        return sections
        
    }
    
    /// Returns the title for the section with the specified index.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case folderSectionIndex:
            return folderSectionTitle
        case itemSectionIndex:
            return itemSectionTitle
        default:
            fatalInvalidIndexPath()
        }
    }
    
    /// Returns the number of rows to display for the section with the specified index.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case folderSectionIndex:
            return folder.subfolders.count
        case itemSectionIndex:
            return folder.items.count
        default:
            fatalInvalidIndexPath()
        }
    }
    
    /// Returns the cell to display for the row at the specified index path.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case folderSectionIndex:
            return self.tableView(tableView, cellForFolder: folder(at: indexPath), at: indexPath)
        case itemSectionIndex:
            return self.tableView(tableView, cellForItem: item(at: indexPath), at: indexPath)
        default:
            fatalInvalidIndexPath()
        }
    }
    
    // MARK: UITableViewDelegate
    
    /// The table view will display the specified cell.
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
            
        case folderSectionIndex:
            break
            
        case itemSectionIndex:
            guard traitCollection.horizontalSizeClass != .compact else { return }
            cell.isSelected = (item(at: indexPath) == viewModel.selectedItem.value)
            
        default:
            fatalInvalidIndexPath()
            
        }
    }
    
    /// The user tapped the cell at the specified index path.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
            
        case folderSectionIndex:
            performSegue(withIdentifier: "ShowFolder", sender: folder(at: indexPath))
            tableView.deselectRow(at: indexPath, animated: true)
            
        case itemSectionIndex:
            viewModel.selectedItem.value = item(at: indexPath)
            if traitCollection.horizontalSizeClass == .compact {
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                reloadItemsSection()
            }
            
        default:
            fatalInvalidIndexPath()
            
        }
    }
    
    /// The table view will attempt to deselect a row.
    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil // prevents user from manually deselecting selected rows
    }
    
    // MARK: Segue Actions
    
    /// Creates and returns a folder view controller instance.
    @IBSegueAction
    private func createFolderViewController(_ coder: NSCoder, sender: Any?) -> UIViewController? {
        guard let folder = sender as? Folder<ViewModel.Item> else { fatalInvalidSegue() }
        return folderViewController(coder: coder, viewModel: viewModel, folder: folder)
    }
    
    // MARK: Protected Utility
    
    /// Returns the title for the folders section.
    /// - note: Subclasses must implement!
    var folderSectionTitle: String {
        fatalSubclassMustImplement()
    }
    
    /// Returns the title for the items section.
    /// - note: Subclasses must implement!
    var itemSectionTitle: String {
        fatalSubclassMustImplement()
    }
    
    /// Returns a folder view controller for the specified parameters.
    /// - note: Subclasses must implement!
    func folderViewController(coder: NSCoder, viewModel: ViewModel, folder: Folder<ViewModel.Item>) -> UIViewController? {
        fatalSubclassMustImplement()
    }
    
    /// Returns a table view cell for the specified folder.
    /// - note: Subclasses must implement!
    func tableView(_ tableView: UITableView, cellForFolder folder: Folder<ViewModel.Item>, at indexPath: IndexPath) -> UITableViewCell {
        fatalSubclassMustImplement()
    }
    
    /// Returns a table view cell for the specified item.
    func tableView(_ tableView: UITableView, cellForItem item: ViewModel.Item, at indexPath: IndexPath) -> UITableViewCell {
        fatalSubclassMustImplement()
    }
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
        
        // Update selected cell when the selected item changes
        viewModel.selectedItem.producer.take(duringLifetimeOf: self).startWithValues { [unowned self] _ in
            
            // If the table view is not currently displayed, then defer until it is
            guard self.view.window != nil else {
                self.deferredTableViewUpdate = true
                return
            }
            
            // If it *is* displayed, then update the items section to change the selected cell
            self.reloadItemsSection()
            
        }
        
        // If the folder for this binder becomes unavailable, pop to the root view controller
        viewModel.binders.producer.skip(first: 1).take(duringLifetimeOf: self).startWithValues { [unowned self] binders in
            if !binders.contains(where: { $0.contains(folder: self.folder) }) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
    }
    
    /// Reloads the items section, if it is displayed.
    private func reloadItemsSection() {
        guard isItemSectionDisplayed else { return }
        let indexSet = IndexSet(integer: itemSectionIndex)
        tableView.reloadSections(indexSet, with: .none)
    }
    
    /// Returns the folder at the specified `IndexPath`.
    private func folder(at indexPath: IndexPath) -> Folder<ViewModel.Item> {
        guard
            isFolderSectionDisplayed,
            indexPath.section == folderSectionIndex
            else { fatalInvalidIndexPath() }
        return folder.subfolders[indexPath.row] as Folder<ViewModel.Item>
    }
    
    /// Returns the item at the specified `IndexPath`.
    private func item(at indexPath: IndexPath) -> ViewModel.Item {
        guard
            isItemSectionDisplayed,
            indexPath.section == itemSectionIndex
            else { fatalInvalidIndexPath() }
        return folder.items[indexPath.row]
    }
    
    /// Returns `true` if the folders section should be displayed.
    private var isFolderSectionDisplayed: Bool {
        return !folder.subfolders.isEmpty
    }
    
    /// Returns `true` if the items section should be displayed.
    private var isItemSectionDisplayed: Bool {
        return !folder.items.isEmpty
    }
    
    /// Returns the index of the folders section.
    private var folderSectionIndex: Int {
        guard isFolderSectionDisplayed else { return -1 }
        return 0
    }
    
    /// Returns the index of the items section.
    private var itemSectionIndex: Int {
        guard isItemSectionDisplayed else { return -1 }
        return (isFolderSectionDisplayed ? 1 : 0)
    }
    
}
