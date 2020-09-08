//
//  ReferenceDocumentType.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/16/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Enumeration of valid reference document types.
enum ReferenceDocumentType: String, Codable {

    // MARK: Cases
    
    /// Document is an HTML document.
    case html
    
    // MARK: Properties
    
    /// The filename extension for this document type.
    var `extension`: String {
        switch self {
        case .html:
            return "html"
        }
    }
    
}
