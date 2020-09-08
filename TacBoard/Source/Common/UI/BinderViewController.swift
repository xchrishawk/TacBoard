//
//  BinderViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/15/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift
import UIKit

/// Abstract base class for master view controllers displaying available binders and their folders.
class BinderViewController<ViewModel>: TableViewController where ViewModel: BinderViewModel {
    
    // MARK: Fields
    
    @IBOutlet private var noItemsView: UIView?
    @IBOutlet private var noItemsLabel: UILabel?
    
    // MARK: Initialization
    
    /// Initializer not available.
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalNotAvailable() }
    
    /// Initializes a new instance with the specified view model.
    init?(coder: NSCoder, viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    // MARK: Fields
    
    /// The view model for this view controller.
    let viewModel: ViewModel
    
    // MARK: UIViewController Overrides
    
    /// Initializes the view controller after the view loads.
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeBindings()
    }
    
    // MARK: UITableViewDataSource
    
    /// Returns the number of sections to display.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.binders.value.count
    }
    
    /// Returns the title to display for the section at the specified index.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return binder(at: section).title
    }
    
    /// Returns the number of rows to display in the specified section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return binder(at: section).folders.count
    }
    
    /// Returns a cell for the specified index path.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.tableView(tableView, cellForFolder: folder(at: indexPath), at: indexPath)
    }
    
    // MARK: UITableViewDelegate
    
    /// The user selected the cell at the specified index path.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowFolder", sender: folder(at: indexPath))
    }
    
    // MARK: Segue Actions
    
    /// Creates and returns a folder view controller instance.
    @IBSegueAction
    private func createFolderViewController(_ coder: NSCoder, sender: Any?) -> UIViewController? {
        guard let folder = sender as? Folder<ViewModel.Item> else { fatalInvalidSegue() }
        return folderViewController(coder: coder, viewModel: viewModel, folder: folder)
    }
    
    // MARK: Protected Utility
    
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
    
    /// Returns a `String` explaining why there are no items available.
    /// - note: Subclasses must implement!
    func noItemsAvailableExplanation(viewModel: ViewModel) -> String {
        fatalSubclassMustImplement()
    }
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
        
        // Reload the table view when the available binders change
        viewModel.binders.producer.take(duringLifetimeOf: self).startWithValues { [unowned self] _ in
            self.tableView.reloadData()
            self.noItemsAvailableText = {
                guard self.viewModel.binders.value.isEmpty else { return nil }
                return self.noItemsAvailableExplanation(viewModel: self.viewModel)
            }()
        }
        
    }
    
    /// Returns the binder for the specified section index.
    private func binder(at section: Int) -> Binder<ViewModel.Item> {
        return viewModel.binders.value[section]
    }
    
    /// Returns the folder for the specified index path.
    private func folder(at indexPath: IndexPath) -> Folder<ViewModel.Item> {
        return binder(at: indexPath.section).folders[indexPath.row]
    }
    
    /// The "No Items" explanation text to display.
    /// - note: If set to `nil`, the label will be hidden.
    private var noItemsAvailableText: String? = nil {
        didSet {
            noItemsLabel?.text = noItemsAvailableText
            isNoItemsAvailableViewHidden = noItemsAvailableText.isNilOrEmpty
        }
    }
    
    /// If set to `true`, the "No Items" view will be hidden.
    private var isNoItemsAvailableViewHidden = true {
        didSet {
            
            guard
                isNoItemsAvailableViewHidden != oldValue,
                let noItemsView = noItemsView
                else { return }
            
            if isNoItemsAvailableViewHidden {
                
                // Hide view
                noItemsView.removeFromSuperview()
                
            } else {
                
                // Show view
                view.addSubview(noItemsView)
                noItemsView.translatesAutoresizingMaskIntoConstraints = false
                noItemsView.centerXAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerXAnchor).isActive = true
                noItemsView.centerYAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerYAnchor).isActive = true
                noItemsView.widthAnchor.constraint(lessThanOrEqualTo: tableView.safeAreaLayoutGuide.widthAnchor, constant: -20.0).isActive = true
                noItemsView.sizeToFit()
                
            }
            
        }
    }
}
