//
//  ChecklistViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Main view controller for the checklists page.
class ChecklistViewController: UIViewController {
    
    // MARK: Fields
    
    private let viewModel: ChecklistViewModel
    private var embeddedSplitViewController: UISplitViewController?
    
    // We have to hang on to a reference here because the delegate is weak on UISplitViewController
    private lazy var splitViewControllerDelegate: SplitViewControllerDelegate = {
        return SplitViewControllerDelegate(createDetailNavigationController: { [unowned self] in self.createDetailNavigationController() },
                                           createDetailViewController: { [unowned self] in self.createDetailViewController(for: self.viewModel.selectedItem.value!) },
                                           createPlaceholderViewController: { [unowned self] in self.createPlaceholderViewController() },
                                           isItemSelected: { [unowned self] in (self.viewModel.selectedItem.value != nil) })
    }()
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified coder.
    /// - note: The shared `ChecklistViewModel` will be used.
    required init?(coder: NSCoder) {
        self.viewModel = ChecklistViewModel.shared
        super.init(coder: coder)
    }
    
    /// Initializes a new instance with the specified coder and view model.
    init?(coder: NSCoder, viewModel: ChecklistViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    // MARK: UIViewController Overrides
    
    /// Initializes the view controller after the view loads.
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeBindings()
    }
    
    /// Prepares for the specified segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            
        case "EmbedSplitViewController":
            guard let controller = segue.destination as? UISplitViewController else { fatalInvalidSegue() }
            embeddedSplitViewController = controller
            embeddedSplitViewController?.delegate = splitViewControllerDelegate
            embeddedSplitViewController?.observeSplitDisplayModeProperty(viewModel.splitDisplayMode)
            
        default:
            break
            
        }
    }
    
    // MARK: Segue Actions
    
    /// Creates and returns a `ChecklistBinderViewController` instance.
    @IBSegueAction
    private func createChecklistBinderViewController(_ coder: NSCoder) -> UIViewController? {
        return ChecklistBinderViewController(coder: coder, viewModel: viewModel)
    }
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
        
        // Update the detail view controller when the selected procedure changes
        viewModel.selectedItem.producer.take(duringLifetimeOf: self).startWithValues { [unowned self] selectedItem in
            self.embeddedSplitViewController?.showDetailViewController({
                if let selectedItem = selectedItem {
                    return self.createDetailViewController(for: selectedItem)
                } else {
                    return self.createPlaceholderViewController()
                }
            }(), sender: nil)
        }
        
    }
    
    /// Creates a detail navigation controller.
    private func createDetailNavigationController() -> UINavigationController {
        return UIStoryboard.App.checklists.instantiateViewController(identifier: "DetailNavigation") { coder in
            return UINavigationController(coder: coder)
        }
    }
    
    /// Creates a detail view controller for the specified procedure.
    private func createDetailViewController(for procedure: ChecklistProcedure) -> UIViewController {
        return UIStoryboard.App.checklists.instantiateViewController(identifier: "Procedure") { coder in
            return ChecklistProcedureViewController(coder: coder, viewModel: self.viewModel, procedure: procedure)
        }
    }
    
    /// Creates a placeholder view controller.
    private func createPlaceholderViewController() -> PlaceholderViewController {
        return UIStoryboard.App.checklists.instantiateViewController(identifier: "Placeholder") { coder in
            return PlaceholderViewController(coder: coder)
        }
    }
    
}
