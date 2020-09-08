//
//  MediaFrameViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/22/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift
import UIKit

/// View controller displaying a utility frame for some media type.
class MediaFrameViewController: UIViewController, SplitDisplayModeTogglingViewController {
    
    // MARK: Constants
    
    /// The default brightness to use for dark mode.
    static let defaultDarkModeBrightness: CGFloat = 0.5
    
    // MARK: Fields
    
    private let content: UIViewController
    private let splitDisplayMode: MutableProperty<SplitDisplayMode>
    private let darkModeBrightness: MutableProperty<CGFloat>
    private let credit: String?
    private let disclaimer: String?
    
    // MARK: Outlets
    
    @IBOutlet private var containerView: UIView?
    
    @IBOutlet private var brightnessView: UIView?
    @IBOutlet private var brightnessSlider: UISlider?
    
    @IBOutlet private var labelView: UIView?
    @IBOutlet private var labelViewBottomSpacingContraint: NSLayoutConstraint?
    @IBOutlet private var creditLabel: UILabel?
    @IBOutlet private var disclaimerView: UIView?
    @IBOutlet private var disclaimerLabel: UILabel?
    
    @IBOutlet var splitDisplayModeBarButtonItem: UIBarButtonItem? // needs to be non-private for SplitDisplayModeTogglingViewController
    
    // MARK: Initialization
    
    /// Initializer not available.
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalNotAvailable() }

    /// Initializes a new instance with the specified values.
    init?(coder: NSCoder,
          content: UIViewController,
          splitDisplayMode: MutableProperty<SplitDisplayMode>,
          darkModeBrightness: MutableProperty<CGFloat>,
          title: String? = nil,
          credit: String? = nil,
          disclaimer: String? = nil) {
        
        self.content = content
        self.splitDisplayMode = splitDisplayMode
        self.darkModeBrightness = darkModeBrightness
        self.credit = credit
        self.disclaimer = disclaimer
        
        super.init(coder: coder)
        
        self.title = title
        
    }
    
    // MARK: UIViewController Overrides
    
    /// Initializes the view controller after the view has loaded.
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let containerView = containerView {
        
            // Embed the content view controller
            content.willMove(toParent: self)
            containerView.addSubview(content.view)
            addChild(content)
            content.didMove(toParent: self)
            
            // Set up constraints
            content.view.translatesAutoresizingMaskIntoConstraints = false
            containerView.addConstraints([
                containerView.leftAnchor.constraint(equalTo: content.view.leftAnchor),
                containerView.rightAnchor.constraint(equalTo: content.view.rightAnchor),
                containerView.topAnchor.constraint(equalTo: content.view.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: content.view.bottomAnchor)
            ])
            
        }
        
        // Update page title
        navigationItem.title = title
        
        // Update labels
        let hasCreditOrDisclaimer = !(credit.isNilOrEmpty && disclaimer.isNilOrEmpty)
        creditLabel?.text = credit
        creditLabel?.safeIsHidden = credit.isNilOrEmpty
        disclaimerLabel?.text = disclaimer
        disclaimerLabel?.safeIsHidden = disclaimer.isNilOrEmpty
        disclaimerView?.safeIsHidden = disclaimer.isNilOrEmpty
        labelView?.safeIsHidden = !hasCreditOrDisclaimer
        labelViewBottomSpacingContraint?.isActive = hasCreditOrDisclaimer
        
        // Initialize state
        updateContentAlpha()
        updateBrightnessViewIsHidden()
        updateIsSplitDisplayModeButtonHidden()
        
        initializeBindings()
        
    }
    
    /// Called when the view will transition to a new size.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateIsSplitDisplayModeButtonHidden(coordinator: coordinator)
    }
    
    /// Called when the view will transition to the specified trait collection.
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.willTransition(to: newCollection, with: coordinator)
        
        // Update for new UI mode
        coordinator.animate(alongsideTransition: { _ in
            self.updateContentAlpha(for: newCollection)
            self.updateBrightnessViewIsHidden(for: newCollection)
        }, completion: nil)
        
        updateIsSplitDisplayModeButtonHidden(with: newCollection, coordinator: coordinator)
        
    }
    
    // MARK: Actions
    
    /// The user pressed the show/hide menu button.
    @IBAction
    private func splitDisplayModeBarButtonItemPressed(_ sender: UIBarButtonItem) {
        splitDisplayMode.value.toggle()
    }
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
        
        // Bind the brightness slider to the view model
        if let brightnessSlider = brightnessSlider {
            brightnessSlider.value = Float(darkModeBrightness.value)
            darkModeBrightness <~ brightnessSlider.reactive.values.map { CGFloat($0) }
        }

        // Update the image alpha when it changes
        darkModeBrightness.producer.take(duringLifetimeOf: self).startWithValues { [unowned self] _ in
            self.updateContentAlpha()
        }
        
    }
    
    /// Displays or hides the brightness view depending on the current UI style.
    private func updateBrightnessViewIsHidden(for traitCollection: UITraitCollection? = nil) {
        let traitCollection = traitCollection ?? self.traitCollection
        brightnessView?.safeIsHidden = (traitCollection.userInterfaceStyle != .dark)
    }
    
    /// Updates the currently displayed image.
    private func updateContentAlpha(for traitCollection: UITraitCollection? = nil) {
        let traitCollection = traitCollection ?? self.traitCollection
        containerView?.alpha = {
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return darkModeBrightness.value
            default:
                return 1.0
            }
        }()
    }
    
}
