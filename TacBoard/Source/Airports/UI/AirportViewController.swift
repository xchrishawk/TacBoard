//
//  AirportsViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/4/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Root view controller for the Airports page.
class AirportViewController: UIViewController {
    
    // MARK: Fields
    
    private let viewModel: AirportViewModel
    private var embeddedSplitViewController: UISplitViewController?
    
    // We have to hang on to a reference here because the delegate is weak on UISplitViewController
    private lazy var splitViewControllerDelegate: SplitViewControllerDelegate = {
        return SplitViewControllerDelegate(createDetailNavigationController: { [unowned self] in self.createDetailNavigationController() },
                                           createDetailViewController: { [unowned self] in self.createDetailViewController(for: self.viewModel.selectedAirport.value!) },
                                           createPlaceholderViewController: { [unowned self] in self.createPlaceholderViewController() },
                                           isItemSelected: { [unowned self] in (self.viewModel.selectedAirport.value != nil) })
    }()
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified coder.
    required init?(coder: NSCoder) {
        self.viewModel = AirportViewModel.shared
        super.init(coder: coder)
    }
    
    /// Initializes a new instance with the specified coder and view model.
    init?(coder: NSCoder, viewModel: AirportViewModel) {
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
    
    /// Creates and returns an `AirportListViewController` instance.
    @IBSegueAction
    private func createAirportListViewController(_ coder: NSCoder) -> UIViewController? {
        return AirportListViewController(coder: coder, viewModel: viewModel)
    }
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {

        // Update the detail view controller when the selected airport changes
        viewModel.selectedAirport.producer.take(duringLifetimeOf: self).startWithValues { [unowned self] selectedAirport in
            self.embeddedSplitViewController?.showDetailViewController({
                if let selectedAirport = selectedAirport {
                    return self.createDetailViewController(for: selectedAirport)
                } else {
                    return self.createPlaceholderViewController()
                }
            }(), sender: nil)
        }
        
    }
    
    /// Creates a detail navigation controller.
    private func createDetailNavigationController() -> UINavigationController {
        return UIStoryboard.App.airports.instantiateViewController(identifier: "DetailNavigation") { coder in
            return UINavigationController(coder: coder)
        }
    }
    
    /// Creates a detail view controller for the specified airport.
    private func createDetailViewController(for airport: Airport) -> UIViewController {
        return UIStoryboard.App.airports.instantiateViewController(identifier: "AirportDetail") { coder in
            return AirportDetailViewController(coder: coder, viewModel: self.viewModel, airport: airport)
        }
    }
    
    /// Creates a placeholder view controller.
    private func createPlaceholderViewController() -> PlaceholderViewController {
        return UIStoryboard.App.airports.instantiateViewController(identifier: "Placeholder") { coder in
            return PlaceholderViewController(coder: coder)
        }
    }

}
