//
//  AirportImageViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/5/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import UIKit

/// View controller displaying an airport image in a scrollable view.
class AirportImageViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: Fields
    
    private let viewModel: AirportViewModel
    private let airport: Airport
    private let airportImage: AirportImage
    
    // MARK: Outlets
    
    @IBOutlet private var scrollView: UIScrollView?
    @IBOutlet private var contentView: UIView?
    @IBOutlet private var imageView: UIImageView?
    @IBOutlet private var downloadActivityIndicatorView: UIActivityIndicatorView?
    @IBOutlet private var downloadFailedLabel: UILabel?
    
    // MARK: Initialization
    
    /// Initializer not available.
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalNotAvailable() }

    /// Initializes a new instance with the specified coder and view model.
    init?(coder: NSCoder, viewModel: AirportViewModel, airport: Airport, airportImage: AirportImage) {
        self.viewModel = viewModel
        self.airport = airport
        self.airportImage = airportImage
        super.init(coder: coder)
    }
    
    // MARK: UIViewController Overrides
    
    /// Initializes the view controller after the view loads.
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeImageView()
    }
    
    /// Called when the view is about to appear.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    /// Called when the view lays out its subviews.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateMinimumZoom()
        updateContentInset()
    }
    
    // MARK: UIScrollViewDelegate
    
    /// Returns the view which should be displayed while zooming.
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    /// The scroll view changed its zoom level.
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentInset()
    }
    
    // MARK: Actions
    
    /// The user double-tapped the scroll view.
    @IBAction
    private func scrollViewDoubleTapped(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: Constants.defaultAnimationDuration) {
            
            guard let scrollView = self.scrollView else { return }
            
            if abs(scrollView.zoomScale - scrollView.minimumZoomScale) < 0.001 {
                self.zoomToMaximum()
            } else {
                self.zoomToMinimum()
            }
            
        }
    }
    
    // MARK: Private Utility
    
    /// Initializes the image view.
    private func initializeImageView() {
        
        downloadActivityIndicatorView?.startAnimating()
        
        viewModel.image(for: airportImage) { [weak self] image in
            self?.downloadActivityIndicatorView?.stopAnimating()
            if let image = image {
                
                // Successfully got image
                self?.imageView?.image = image
                self?.initializeScrollView()
                
            } else {
                
                // Download failed for some reason
                self?.downloadFailedLabel?.isHidden = false
                
            }
        }
        
    }
    
    /// Initializes the scroll view after the image is displayed.
    private func initializeScrollView() {
        
        // NOTE - we have to dispatch to give the UI a loop to figure out the image size
        DispatchQueue.main.async { [weak self] in
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()
            self?.zoomToMinimum()
        }
        
    }
    
    /// Zooms the scroll view to its minimum zoom scale.
    private func zoomToMinimum() {
        guard let scrollView = scrollView else { return }
        scrollView.zoomScale = scrollView.minimumZoomScale
    }
    
    /// Zooms the scroll view to its maximum zoom scale.
    private func zoomToMaximum() {
        guard let scrollView = scrollView else { return }
        scrollView.zoomScale = scrollView.maximumZoomScale
    }
    
    /// Updates the minimum zoom scale for the scroll view.
    private func updateMinimumZoom() {
        
        guard let scrollView = scrollView else { return }

        let padding: CGFloat = 0.05
        let minZoomX = (scrollView.frame.size.width / scrollView.contentLayoutGuide.layoutFrame.size.width) * (1.0 - padding)
        let minZoomY = (scrollView.frame.size.height / scrollView.contentLayoutGuide.layoutFrame.size.height) * (1.0 - padding)

        scrollView.minimumZoomScale = min(minZoomX, minZoomY, 1.0)
        scrollView.maximumZoomScale = 1.0

        if scrollView.zoomScale < scrollView.minimumZoomScale {
            zoomToMinimum()
        }
        
    }
    
    /// Updates the scroll view content inset to keep the image centered.
    private func updateContentInset() {
        
        guard let scrollView = scrollView else { return }

        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)

        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0.0, right: 0.0);
        
    }
    
}
