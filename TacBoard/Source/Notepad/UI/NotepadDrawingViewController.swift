//
//  NotepadDrawingViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/2/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift
import UIKit

/// View controller for drawing.
class NotepadDrawingViewController: UIViewController {
    
    // MARK: Fields
    
    private let viewModel: NotepadViewModel
    private let page: NotepadPage

    // MARK: Outlets

    @IBOutlet private var backgroundView: UIView?
    @IBOutlet private var drawingView: NotepadDrawingView?
    
    // MARK: Initialization

    /// Initializer not available.
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalNotAvailable() }
    
    /// Initializes a new instance with the specified coder, view model, and page.
    init?(coder: NSCoder, viewModel: NotepadViewModel, page: NotepadPage) {
        self.viewModel = viewModel
        self.page = page
        super.init(coder: coder)
    }
    
    // MARK: UIViewController Overrides
    
    /// Initializes the view controller after the view is loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeBindings()
    }
    
    /// Redraws the view when its size changes.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.backgroundView?.setNeedsDisplay()
            self.drawingView?.setNeedsDisplay()
        }, completion: nil)
    }
    
    // MARK: Methods
    
    /// Undoes the most recent action.
    func undo() {
        _ = paths.value.popLast()
    }
    
    /// Clears the drawing view.
    func clear() {
        paths.value.removeAll()
    }
 
    // MARK: Actions
    
    /// The user did a pan gesture on the drawing view.
    @IBAction
    private func drawingGesture(_ sender: UIGestureRecognizer) {
        
        guard let drawingView = drawingView else { return }
        
        // Convert the point to normalized coordinates
        let point = sender.location(in: drawingView).applying(drawingView.transformViewToNormalized)
        
        // Action depends on the current state
        let activePath = viewModel.activePath(page: page)
        switch sender.state {
            
        case .began:
            activePath.value = NotepadPath(at: point,
                                           color: viewModel.activePathColor.value,
                                           width: viewModel.activePathWidth.value)
            
        case .changed:
            activePath.value?.addLine(to: point)
            
        case .ended:
            activePath.value?.addLine(to: point)
            if let activePath = activePath.value { paths.value.append(activePath) }
            activePath.value = nil
            
        default:
            break
            
        }
        
    }
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
     
        // Update the drawing view's paths when needed
        let producer = SignalProducer.combineLatest(paths.producer, activePath.producer)
        producer.take(duringLifetimeOf: self).startWithValues { [unowned self] (paths, activePath) in
            var paths = paths
            if let activePath = activePath { paths.append(activePath) }
            self.drawingView?.paths = paths
        }
        
    }
    
    /// The currently displayed completed paths.
    private var paths: MutableProperty<[NotepadPath]> {
        return viewModel.paths(page: page)
    }
    
    /// The active path, if any.
    private var activePath: MutableProperty<NotepadPath?> {
        return viewModel.activePath(page: page)
    }
    
}
