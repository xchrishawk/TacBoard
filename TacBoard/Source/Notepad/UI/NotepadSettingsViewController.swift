//
//  NotepadSettingsViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/3/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import UIKit

// MARK: - NotepadSettingsPopoverContainerViewController

/// Popover container view controller for `NotepadSettingsViewController`.
class NotepadSettingsPopoverContainerViewController: ViewModelPopoverContainerViewController<NotepadViewModel> {

    // MARK: Segue Actions
    
    /// Creates and returns a `NotepadSettingsViewController` instance.
    @IBSegueAction
    private func createSettingsViewController(_ coder: NSCoder) -> UIViewController? {
        return NotepadSettingsViewController(coder: coder, viewModel: viewModel)
    }
    
}

// MARK: - NotepadSettingsViewController

/// View controller for the notepad settings.
class NotepadSettingsViewController: TableViewController {
    
    // MARK: Fields
    
    private let viewModel: NotepadViewModel
    
    // MARK: Outlets
    
    @IBOutlet private var activePathWidthSlider: UISlider?
    @IBOutlet private var activeColorButtons: [UIButton]?
    @IBOutlet private var eraseButton: UIButton?
    @IBOutlet private var tintColorButton: UIButton?
    
    // MARK: Initialization

    /// Initializer not available.
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalNotAvailable() }
    
    /// Initializes a new instance with the specified coder and view model.
    init?(coder: NSCoder, viewModel: NotepadViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    // MARK: UIViewController Overrides
    
    /// Initializes the view controller after the view has loaded.
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // If this is set in the storyboard, it doesn't get matched as "equal"
        tintColorButton?.tintColor = UIColor(application: .tint)

        // Update images for buttons
        if let activeColorButtons = activeColorButtons {
            for activeColorButton in activeColorButtons {
                activeColorButton.setImage(UIImage(systemName: "pencil.circle"), for: .normal)
                activeColorButton.setImage(UIImage(systemName: "pencil.circle.fill"), for: .selected)
            }
        }
        
        // This needs to be done after activeColorButtons since eraseButton is a member of activeColorButtons
        eraseButton?.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        eraseButton?.setImage(UIImage(systemName: "xmark.circle.fill"), for: .selected)
        
        // On iPhone, we need to enable scrolling since in landscape mode the entire view may not be displayed
        if UIDevice.current.isPhone {
            tableView.isScrollEnabled = true
            tableView.bounces = true
        }
        
        initializeBindings()
                
    }
    
    // MARK: Actions
    
    /// The user pressed a color button.
    @IBAction
    private func colorButtonPressed(_ sender: UIButton) {
        
        // Update the color
        if sender === eraseButton {
            viewModel.activePathColor.value = UIColor(application: .notepadBackground)
        } else {
            viewModel.activePathColor.value = sender.tintColor
        }
        
        // Unwind to the notepad view controller
        performSegue(withIdentifier: "Dismiss", sender: nil)
        
    }
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
        
        // Color buttons
        viewModel.activePathColor.producer.take(duringLifetimeOf: self).startWithValues { [unowned self] _ in
            self.updateColorButtons()
        }
     
        // Path width slider
        if let activePathWidthSlider = activePathWidthSlider {
            
            activePathWidthSlider.minimumValue = 0.0
            activePathWidthSlider.maximumValue = 1.0
            
            // We add a bit of a curve here to give more resolution at the low end
            let curvature: Float = 2.5
            activePathWidthSlider.value = pow(Float((viewModel.activePathWidth.value - NotepadPath.minimumWidth) / (NotepadPath.maximumWidth - NotepadPath.minimumWidth)), 1.0 / curvature)
            viewModel.activePathWidth <~ activePathWidthSlider.reactive.values.map { value in
                return NotepadPath.minimumWidth + ((NotepadPath.maximumWidth - NotepadPath.minimumWidth) * CGFloat(pow(value, curvature)))
            }
            
        }
        
    }
    
    /// Updates the color buttons for the currently selected color.
    private func updateColorButtons() {
        
        guard let activeColorButtons = activeColorButtons else { return }
        
        // Update all buttons
        for activeColorButton in activeColorButtons {
            activeColorButton.isSelected = viewModel.activePathColor.value.isEqualToColor(activeColorButton.tintColor)
        }
        
        // Erase button is handled specially
        eraseButton?.isSelected = viewModel.activePathColor.value.isEqualToColor(UIColor(application: .notepadBackground))
        
    }

}
