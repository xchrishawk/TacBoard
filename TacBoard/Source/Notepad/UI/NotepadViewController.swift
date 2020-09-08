//
//  NotepadViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/2/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import UIKit

/// Root view controller for the notepad section of the app.
class NotepadViewController: UIViewController {
    
    // MARK: Types
    
    /// Enumeration of animation types supported when embedding a new controller.
    private enum EmbedAnimation {
        
        // No animation should be performed.
        case none
        
        // The new view controller should slide in from the left.
        case slideFromLeft
        
        // The new view controller should slide in from the right.
        case slideFromRight
        
    }
    
    // MARK: Fields
    
    private let viewModel: NotepadViewModel
    
    private var embeddedViewController: NotepadDrawingViewController?
    private var embeddedViewControllerDisposable: Disposable?
    private var previouslySelectedNotepadPage: NotepadPage?
    
    // MARK: Outlets
    
    @IBOutlet private var undoBarButtonItem: UIBarButtonItem?
    @IBOutlet private var clearBarButtonItem: UIBarButtonItem?
    @IBOutlet private var pageSegmentedControl: SegmentedControl?
    @IBOutlet private var containerView: UIView?
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified coder.
    required init?(coder: NSCoder) {
        self.viewModel = NotepadViewModel()
        super.init(coder: coder)
    }
    
    /// Initializes a new instance with the specified coder and view model.
    init?(coder: NSCoder, viewModel: NotepadViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    // MARK: UIViewController Overrides
    
    /// Sets up the view controller
    override func viewDidLoad() {
        super.viewDidLoad()
        pageSegmentedControl?.configure(for: NotepadPage.self)
        initializeBindings()
    }
    
    // MARK: Segue Actions
    
    
    /// Creates and returns a `NotepadSettingsPopoverContainerViewController` instance.
    @IBSegueAction
    private func createSettingsPopoverContainerViewController(_ coder: NSCoder) -> UIViewController? {
        return NotepadSettingsPopoverContainerViewController(coder: coder, viewModel: viewModel)
    }
    
    /// Creates and returns a `NotepadSettingsViewController` instance.
    @IBSegueAction
    private func createSettingsViewController(_ coder: NSCoder) -> UIViewController? {
        return NotepadSettingsViewController(coder: coder, viewModel: viewModel)
    }

    // MARK: Actions
    
    /// Target for unwind segues.
    @IBAction private func unwindToNotepadViewController(_ segue: UIStoryboardSegue) {
        // no-op
    }
    
    /// The user pressed the settings button.
    @IBAction
    private func settingsBarButtonItemPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: (UIDevice.current.isPhone ? "ShowSettingsPush" : "ShowSettingsPopover"), sender: nil)
    }
    
    /// The user pressed the undo button.
    @IBAction
    private func undoBarButtonItemPressed(_ sender: UIBarButtonItem) {
        embeddedViewController?.undo()
    }
    
    /// The user pressed the clear button.
    @IBAction
    private func clearBarButtonItemPressed(_ sender: UIBarButtonItem) {
        embeddedViewController?.clear()
    }

    /// The user changed the page segmented control.
    @IBAction
    private func pageSegmentedControlValueChanged(_ sender: SegmentedControl) {
        viewModel.selectedPage.value = sender.value(for: NotepadPage.self)
    }
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
        
        // Update the selected page when commanded by the view model
        viewModel.selectedPage.producer.take(duringLifetimeOf: self).startWithValues { [unowned self] page in
            self.pageSegmentedControl?.setValue(page, for: NotepadPage.self)
            self.setNotepadPage(page)
        }
        
    }

    /// Sets the currently selected page.
    private func setNotepadPage(_ page: NotepadPage) {
        
        // Determine the animation to use
        let animation: EmbedAnimation = {
            guard let previouslySelectedNotepadPage = previouslySelectedNotepadPage else { return .none }
            if page.rawValue > previouslySelectedNotepadPage.rawValue {
                return .slideFromRight
            } else if page.rawValue < previouslySelectedNotepadPage.rawValue {
                return .slideFromLeft
            } else {
                return .none
            }
        }()
        
        // Embed the new controller
        setEmbeddedViewController(controller(for: page), page: page, animation: animation)
        previouslySelectedNotepadPage = page
        
    }
    
    /// Sets the specified view controller as embedded.
    private func setEmbeddedViewController(_ controller: NotepadDrawingViewController, page: NotepadPage, animation: EmbedAnimation) {

        guard let containerView = containerView else { return }
        
        // Add new view controller, if needed
        controller.willMove(toParent: self)
        containerView.addSubview(controller.view)
        addChild(controller)
        controller.didMove(toParent: self)
        
        // Set initial frame based on the type of
        controller.view.frame = containerView.bounds.offsetBy(dx: {
            switch animation {
            case .slideFromLeft:
                return -containerView.bounds.size.width
            case .slideFromRight:
                return containerView.bounds.size.height
            case .none:
                return 0.0
            }
        }(), dy: 0.0)
        
        // Update state tracking
        let previousEmbeddedViewController = embeddedViewController
        embeddedViewController = controller
        
        // Cancel ReactiveSwift subscriptions to previous controller
        embeddedViewControllerDisposable?.dispose()
        embeddedViewControllerDisposable = nil
        
        // Add new subscriptions to the updated controller
        embeddedViewControllerDisposable = {
            
            let disp = CompositeDisposable()
            
            // Disable the undo button if the drawing is empty
            if let undoBarButtonItem = undoBarButtonItem {
                disp.add(undoBarButtonItem.reactive.isEnabled <~ viewModel.isEmpty(page: page).map { !$0 })
            }
            
            // Disable the clear button if the drawing is empty
            if let clearBarButtonItem = clearBarButtonItem {
                disp.add(clearBarButtonItem.reactive.isEnabled <~ viewModel.isEmpty(page: page).map { !$0 })
            }
            
            return disp
            
        }()
        
        // Perform the animation as required
        UIView.animate(withDuration: (animation != .none ? Constants.defaultAnimationDuration : Constants.noAnimationDuration), delay: 0.0, options: [.curveEaseOut], animations: {
            
            // Move the new view controller into position
            self.embeddedViewController?.view.frame = containerView.bounds
            
            // Move the old view controller out of position
            previousEmbeddedViewController?.view.frame = containerView.bounds.offsetBy(dx: {
                switch animation {
                case .slideFromLeft:
                    return containerView.bounds.size.width
                case .slideFromRight:
                    return -containerView.bounds.size.width
                case .none:
                    return 0.0
                }
            }(), dy: 0.0)
            
        }, completion: { _ in
            
            // Remove the previous view controller now that it's off screen
            if let previousEmbeddedViewController = previousEmbeddedViewController {
                previousEmbeddedViewController.willMove(toParent: nil)
                previousEmbeddedViewController.view.removeFromSuperview()
                previousEmbeddedViewController.removeFromParent()
            }
            
        })

    }
    
    /// Returns the view controller to display for the specified page.
    private func controller(for page: NotepadPage) -> NotepadDrawingViewController {
        return drawingViewController(page: page, identifier: {
            switch page {
            case .blank1, .blank2:
                return "BlankDrawing"
            case .nineLineCAS:
                return "NineLineCASDrawing"
            }
        }())
    }
    
    /// Creates and returns a new `NotepadDrawingViewController`.
    private func drawingViewController(page: NotepadPage, identifier: String) -> NotepadDrawingViewController {
        let viewModel = self.viewModel
        return UIStoryboard.App.notepad.instantiateViewController(identifier: identifier) { coder in
            return NotepadDrawingViewController(coder: coder, viewModel: viewModel, page: page)
        }
    }
    
}
