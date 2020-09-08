//
//  PopoverContainerViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/3/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

// MARK: - PopoverContainerViewController

/// Class for the settings view controller for the notepad.
class PopoverContainerViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet private var contentView: UIView?
    
    // MARK: UIViewController Overrides
    
    /// Initializes the view controller after the view loads.
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Configure popover presentation on iPad
        if !UIDevice.current.isPhone {
            contentView?.layer.borderColor = UIColor(application: .popoverBorder).cgColor
            contentView?.layer.borderWidth = Constants.popoverBorderWidth
            contentView?.layer.cornerRadius = Constants.popoverCornerRadius
        }
        
    }
    
}

// MARK: - ViewModelPopoverContainerViewController

/// Subclass of `PopoverContainerViewController` accepting a view model for `IBSegueAction` purposes.
class ViewModelPopoverContainerViewController<ViewModelType>: PopoverContainerViewController {
    
    // MARK: Initialization
    
    /// Initializer not available.
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalNotAvailable() }
    
    /// Initializes a new instance with the specified coder and view model.
    init?(coder: NSCoder, viewModel: ViewModelType) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    // MARK: Properties
    
    /// The view model to pass on to the container view controller.
    let viewModel: ViewModelType
    
}

