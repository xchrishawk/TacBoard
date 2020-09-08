//
//  ChecklistProcedureViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import UIKit

/// `UITableViewController` subclass displaying a checklist procedure.
class ChecklistProcedureViewController: TableViewController, SplitDisplayModeTogglingViewController {

    // MARK: Fields
    
    private let viewModel: ChecklistViewModel
    private let procedure: ChecklistProcedure
    
    // MARK: Outlets

    @IBOutlet var splitDisplayModeBarButtonItem: UIBarButtonItem? // needs to be non-private for SplitDisplayModeTogglingViewController conformance
    @IBOutlet private var completeResetButton: UIBarButtonItem?
    
    // MARK: Initialization

    /// Initializer not available.
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalNotAvailable() }
    
    /// Initializes a new instance with the specified coder, view model, and procedure.
    init?(coder: NSCoder, viewModel: ChecklistViewModel, procedure: ChecklistProcedure) {
        self.viewModel = viewModel
        self.procedure = procedure
        super.init(coder: coder)
    }
    
    // MARK: UIViewController Overrides
    
    /// Sets up the view controller after the view has loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = procedure.title
        updateIsSplitDisplayModeButtonHidden()
        initializeBindings()
    }
    
    /// The view will transition to a new size.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateIsSplitDisplayModeButtonHidden(coordinator: coordinator)
    }
    
    /// The view will transition to a new trait collection.
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updateIsSplitDisplayModeButtonHidden(with: newCollection, coordinator: coordinator)
    }
    
    // MARK: UITableViewDataSource
    
    /// Returns the number of sections to display.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return procedure.sections.count
    }
    
    /// Returns the title to display for the section at the specified index.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section(at: section).title
    }
    
    /// Returns the number of rows to display in the section with the specified index.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.section(at: section).items.count
    }
    
    /// Returns the cell to display at the specified index path.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.item(at: indexPath)
        if let defaultItem = item as? ChecklistDefaultItem {
            return self.tableView(tableView, cellForDefaultItem: defaultItem, at: indexPath)
        } else if let commentItem = item as? ChecklistCommentItem {
            return self.tableView(tableView, cellForCommentItem: commentItem, at: indexPath)
        } else {
            fatalError("Unrecognized item type!")
        }
    }
    
    // MARK: UITableViewDelegate
    
    /// The user selected the row at the specified index path.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let completableItem = item(at: indexPath) as? ChecklistCompletableItem {
            completableItem.isComplete.value.toggle()
        }
    }
    
    // MARK: Actions
    
    /// The user pressed the complete/reset button.
    @IBAction
    private func completeResetButtonPressed(_ sender: UIBarButtonItem) {
        
        // Toggle the completed state
        let isComplete = !procedure.isComplete.value
        procedure.setIsComplete(isComplete)
        
        //
        // If we set the checklist to complete, and this is iPhone, then pop the detail view controller.
        //
        // NOTE
        // We can't just use self.navigationController, we have to get the nav controller from splitViewController.
        // See https://stackoverflow.com/a/28351685/434245
        //
        if isComplete, UIDevice.current.isPhone, let nav = splitViewController?.viewControllers.first as? UINavigationController {
            nav.popViewController(animated: true)
        }
        
    }
    
    /// The user pressed the show/hide menu button.
    @IBAction
    private func splitDisplayModeBarButtonItemPressed(_ sender: UIBarButtonItem) {
        viewModel.splitDisplayMode.value.toggle()
    }
    
    // MARK: Cell Generation
    
    /// Returns a cell for a `ChecklistDefaultItem` at the specified index path.
    private func tableView(_ tableView: UITableView, cellForDefaultItem item: ChecklistDefaultItem, at indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ChecklistItemTableViewCell
        
        configure(cell, for: item)
        
        cell.selectionStyle = .default
        cell.isCompleteImageView?.reactive.safeIsHidden <~ item.isComplete.producer.take(until: cell.reactive.prepareForReuse).map { !$0 }
        cell.isNotCompleteImageView?.reactive.safeIsHidden <~ item.isComplete.producer.take(until: cell.reactive.prepareForReuse)
        cell.isNotApplicableLabel?.safeIsHidden = true
        
        return cell
        
    }
    
    /// Returns a cell for a `ChecklistCommentItem` at the specified index path.
    private func tableView(_ tableView: UITableView, cellForCommentItem item: ChecklistCommentItem, at indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ChecklistItemTableViewCell
        
        configure(cell, for: item)
        
        cell.selectionStyle = .none
        cell.isCompleteImageView?.safeIsHidden = true
        cell.isNotCompleteImageView?.safeIsHidden = true
        cell.isNotApplicableLabel?.safeIsHidden = true // false - evaluating leaving this turned off
        
        return cell
        
    }
    
    /// Performs common configuration for the specified cell.
    private func configure(_ cell: ChecklistItemTableViewCell, for item: ChecklistItem) {

        cell.itemTextLabel?.text = item.text

        cell.itemSubtextLabel?.text = item.subtext
        cell.itemSubtextLabel?.safeIsHidden = item.subtext.isNilOrEmpty

        cell.itemActionLabel?.text = item.action
        cell.itemActionLabel?.safeIsHidden = item.action.isNilOrEmpty

        cell.itemCommentLabel?.text = item.comment
        cell.itemCommentLabel?.safeIsHidden = item.comment.isNilOrEmpty
        cell.itemCommentView?.safeIsHidden = item.comment.isNilOrEmpty
        cell.itemCommentViewConstraint?.isActive = !item.comment.isNilOrEmpty
        
    }
    
    // MARK: Private Utility

    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
        
        // Update the icon for the complete/reset button
        completeResetButton?.reactive.image <~ procedure.isComplete.map { isComplete in
            return UIImage(systemName: isComplete ? "arrow.clockwise" : "checkmark.circle.fill")
        }
        
    }
    
    /// Returns the `ChecklistSection` at the specified section index.
    private func section(at section: Int) -> ChecklistSection {
        return procedure.sections[section]
    }
    
    /// Returns the `ChecklistItem` at the specified index path.
    private func item(at indexPath: IndexPath) -> ChecklistItem {
        return section(at: indexPath.section).items[indexPath.row]
    }
    
}
