//
//  AirportListViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/6/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import UIKit

/// Master view controller for the airports page.
class AirportListViewController: UIViewController, UITextFieldDelegate {

    // MARK: Fields
    
    private let viewModel: AirportViewModel
    
    // MARK: Outlets
    
    @IBOutlet private var searchTextField: UITextField?
    
    // MARK: Initialization
    
    /// Initializer not available.
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalNotAvailable() }
    
    /// Initializes a new instance with the specified view model and coder.
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
    
    // MARK: Segue Actions
    
    /// Creates and returns an `AirportListTableViewController` instance.
    @IBSegueAction
    private func createAirportListTableViewController(_ coder: NSCoder) -> UIViewController? {
        return AirportListTableViewController(coder: coder, viewModel: viewModel)
    }
    
    // MARK: UITextFieldDelegate
    
    /// Returns `true` if the text field should stop editing.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
        
        // Send search text to the view model
        if let searchTextField = searchTextField {
            viewModel.searchText <~ searchTextField.reactive.continuousTextValues
        }
        
    }
    
}
