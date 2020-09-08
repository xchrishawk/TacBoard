//
//  ReferenceViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/15/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift
import UIKit

/// Main view controller for the Reference section of the app.
class ReferenceViewController: UIViewController {

    // MARK: Fields
    
    private let viewModel: ReferenceViewModel
    private var embeddedSplitViewController: UISplitViewController?
    
    // We have to hang on to a reference here because the delegate is weak on UISplitViewController
    private lazy var splitViewControllerDelegate: SplitViewControllerDelegate = {
        return SplitViewControllerDelegate(createDetailNavigationController: { [unowned self] in self.createDetailNavigationController() },
                                           createDetailViewController: { [unowned self] in self.createDetailViewController(for: self.viewModel.selectedItem.value!) },
                                           createPlaceholderViewController: { [unowned self] in self.createPlaceholderViewController() },
                                           isItemSelected: { [unowned self] in false })
    }()
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified coder.
    required init?(coder: NSCoder) {
        self.viewModel = ReferenceViewModel.shared
        super.init(coder: coder)
    }
    
    /// Initializes a new instance with the specified coder and view model.
    init?(coder: NSCoder, viewModel: ReferenceViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    // MARK: UIViewController Overrides
    
    /// Initializes the view controller after the view has loaded.
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
    
    /// Creates and returns a `ReferenceBinderViewController` instance.
    @IBSegueAction
    private func createReferenceBinderViewController(_ coder: NSCoder) -> UIViewController? {
        return ReferenceBinderViewController(coder: coder, viewModel: viewModel)
    }
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {

        // Update the detail view controller when the selected document changes
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
        return UIStoryboard.App.reference.instantiateViewController(identifier: "DetailNavigation") { coder in
            return UINavigationController(coder: coder)
        }
    }
    
    /// Creates a detail view controller for the specified reference item.
    private func createDetailViewController(for document: ReferenceDocument) -> UIViewController {
        switch document.type {
     
        case .html:
            
            // Create document view controller
            let documentController = UIStoryboard.App.reference.instantiateViewController(identifier: "HTMLDocument") { coder in
                return ReferenceDocumentHTMLViewController(coder: coder, viewModel: self.viewModel, document: document)
            }
            
            // Create frame view controller
            // NOTE: I tried to create a storyboard reference in the Reference storyboard, but for some reason it didn't work with the coder block
            return UIStoryboard.App.common.instantiateViewController(identifier: "MediaFrame") { coder in
                return MediaFrameViewController(coder: coder,
                                                content: documentController,
                                                splitDisplayMode: self.viewModel.splitDisplayMode,
                                                darkModeBrightness: self.viewModel.darkModeBrightness,
                                                title: document.title,
                                                credit: document.credit,
                                                disclaimer: LocalizableString(.referenceDocumentDisclaimer))
            }
            
        }
    }
    
    /// Creates a placeholder view controller.
    private func createPlaceholderViewController() -> PlaceholderViewController {
        return UIStoryboard.App.reference.instantiateViewController(identifier: "Placeholder") { coder in
            return PlaceholderViewController(coder: coder)
        }
    }
    
}
