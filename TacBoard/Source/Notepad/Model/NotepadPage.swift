//
//  NotepadPage.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/3/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

/// Enumeration of notepad pages.
enum NotepadPage: String, CaseIterable, CustomStringConvertible, Defaultable {
    
    // MARK: Cases
    
    /// A blank page.
    case blank1
    
    /// A blank page.
    case blank2
    
    /// A 9-line pre-attack briefing.
    case nineLineCAS
    
    // MARK: Constants
    
    /// The default notepad page to display.
    static let `default`: NotepadPage = .blank1
    
    // MARK: Properties
    
    /// A string describing this enum value.
    var description: String {
        switch self {
        case .blank1:
            return LocalizableString(.notepadPageBlank1)
        case .blank2:
            return LocalizableString(.notepadPageBlank2)
        case .nineLineCAS:
            return LocalizableString(.notepadPageNineLineCAS)
        }
    }
    
}
