//
//  ReferenceDocumentHTMLViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/16/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit
import WebKit

/// View controller with an embedded web viewer to display an HTML file.
class ReferenceDocumentHTMLViewController: UIViewController, WKNavigationDelegate {

    // MARK: Fields
    
    private let viewModel: ReferenceViewModel
    private let document: ReferenceDocument
    
    @IBOutlet private var webView: WKWebView?
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView?
    
    // MARK: Initialization
    
    /// Initializer not available.
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalNotAvailable() }

    /// Initializes a new instance with the specified values.
    init?(coder: NSCoder, viewModel: ReferenceViewModel, document: ReferenceDocument) {
        guard document.type == .html else { fatalError("Invalid document type!") }
        self.viewModel = viewModel
        self.document = document
        super.init(coder: coder)
    }
    
    // MARK: UIViewController Overrides
    
    /// Initializes the view controller after the view loads.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = document.title
        initializeWebView()
    }
    
    // MARK: WKNavigationDelegate
    
    /// Display the web view when loading completes.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoadingPage = false
    }

    /// Display the web view when loading fails.
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoadingPage = false
    }
    
    /// Decides the policy for the requested navigation action.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // If this is a request for the original page, then allow it
        let (originalURL, _) = documentURLs
        guard
            let navigationURL = navigationAction.request.url,
            let navigationURLDeletingFragment = navigationURL.deletingFragment(),
            navigationURL != originalURL,
            navigationURLDeletingFragment != originalURL
            else { decisionHandler(.allow); return }
        
        // Otherwise, cancel the navigation and tell the view model to select the relevant document
        decisionHandler(.cancel)
        viewModel.selectItem(at: navigationURL)
        
    }
    
    // MARK: Private Utility
    
    /// Sets up the web view to display the document.
    private func initializeWebView() {
        
        // Set delegate (no outlet available?)
        webView?.navigationDelegate = self
        
        // Animate spinner while loading
        isLoadingPage = true
        
        // Action depends on whether URLs are local or remote
        let (url, baseURL) = documentURLs
        if url.isFileURL {
         
            // Load local file
            webView?.loadFileURL(url, allowingReadAccessTo: baseURL)
            
        } else {
            
            // Load remote file
            let request = URLRequest(url: url)
            webView?.load(request)
            
        }
        
    }
    
    /// Updates the UI based on whether or not a page is currently loading.
    private var isLoadingPage: Bool = false {
        didSet {
            guard isLoadingPage != oldValue else { return }
            (isLoadingPage ? activityIndicatorView?.startAnimating() : activityIndicatorView?.stopAnimating())
            webView?.safeIsHidden = isLoadingPage
        }
    }
    
    /// Returns the URL for the document to be loaded.
    private var documentURLs: (url: URL, baseURL: URL) {
        switch document.location {
         
        case .asset(let resourceName):
            
            // Search by resource name
            guard
                let url = Bundle.main.url(forResource: resourceName, withExtension: "html"),
                let baseURL = Bundle.main.resourceURL
                else { fatalInvalidResource() }
            return (url, baseURL)
            
        case .relative(let path):
            
            // Search based on current content settings
            return (viewModel.url(forRelativePath: path), viewModel.baseURL)
            
        }
    }
    
}
