//
//  WKWebView.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/16/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView {

    /// Adds a `WKUserScript` to automatically load the CSS file at the specified document.
    /// - note: URL must be valid or the app will crash with a `fatalError()`.
    func addUserScriptToAutoLoadCSS(at url: URL) {
        
        // Get the resource at the specified URL
        guard var css = try? String(contentsOf: url) else { fatalInvalidResource() }
        
        // Create the script to add the style element
        css = css.components(separatedBy: .newlines).joined(separator: " ")
        let source = "var style = document.createElement('style');\nstyle.innerHTML = '\(css)'; document.head.appendChild(style);"
        
        // Run the script when the web view displays the HTML file
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
        
        
    }

    /// Adds a `WKUserScript` to force zoom to 100% and disable user scaling.
    func addUserScriptToDisableScaling() {
        
        let source = "var meta = document.createElement('meta'); " +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "document.head.appendChild(meta);"
        
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
        
    }
    
}
