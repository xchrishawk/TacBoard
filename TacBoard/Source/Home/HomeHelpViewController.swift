//
//  HomeHelpViewController.swift
//  TacBoard
//
//  Created by Chris Vig on 9/12/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit
import WebKit

/// View controller for displaying the help page.
class HomeHelpViewController: UIViewController, WKNavigationDelegate {

    // MARK: Outlets
    
    @IBOutlet private var webView: WKWebView?
    
    // MARK: Properties
    
    /// If set to `true`, the page will default to version history.
    var showVersionHistory: Bool = false
    
    // MARK: UIViewController Overrides
    
    /// Sets up the view controller after the view has loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeWebView()
    }
    
    // MARK: WKNavigationDelegate
    
    /// Decides the navigation policy for the specified action.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // This is only relevante for links to external domains
        guard
            navigationAction.navigationType == .linkActivated,
            let url = navigationAction.request.url,
            !url.isFileURL
            else { decisionHandler(.allow); return }
        
        // Open the URL in an external browser
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        decisionHandler(.cancel)
        
    }
    
    // MARK: Private Utility
    
    /// Initializes the web view to display the help page.
    private func initializeWebView() {
        
        webView?.navigationDelegate = self
        
        guard
            let baseURL = Bundle.main.url(forResource: "Help", withExtension: "html", subdirectory: "Help"),
            let loadURL = URL(string: "\(baseURL.absoluteString)\(showVersionHistory ? "#VersionHistory" : "")")
            else { return }
        
        webView?.loadFileURL(loadURL, allowingReadAccessTo: loadURL.deletingLastPathComponent())
        
    }
    
}
