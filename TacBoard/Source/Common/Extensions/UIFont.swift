//
//  UIFont.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/2/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

//
// NOTE
// This implementation is based on https://stackoverflow.com/a/40484460/434245
//

// MARK: - Constants

private let applicationSystemFontName = "Galvji"
private let applicationBoldSystemFontName = "Galvji-Bold"
private let applicationItalicSystemFontName = "Galvji"     // oblique version not included with iOS

// MARK: - UIFontDescriptor.AttributeName

fileprivate extension UIFontDescriptor.AttributeName {
    
    /// UI usage attribute.
    static let nsctFontUIUsage = UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
    
}

// MARK: - UIFont

extension UIFont {

    // MARK: Static Functions
    
    /// Returns the application-specific system font.
    @objc
    static func applicationSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: applicationSystemFontName, size: size)!
    }
    
    /// Returns the application-specific bold system font.
    @objc
    static func applicationBoldSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: applicationBoldSystemFontName, size: size)!
    }
    
    /// Returns the application-specific italic system font.
    @objc
    static func applicationItalicSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: applicationItalicSystemFontName, size: size)!
    }
    
    /// Performs method swizzling to override the system fonts.
    static func overrideSystemFonts() {
        
        // Basic system font
        if let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
            let applicationSystemFontMethod = class_getClassMethod(self, #selector(applicationSystemFont(ofSize:))) {
            method_exchangeImplementations(systemFontMethod, applicationSystemFontMethod)
        }
        
        // Bold system font
        if let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:))),
            let applicationBoldSystemFontMethod = class_getClassMethod(self, #selector(applicationBoldSystemFont(ofSize:))) {
            method_exchangeImplementations(boldSystemFontMethod, applicationBoldSystemFontMethod)
        }
        
        // Italic system font
        if let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:))),
            let applicationItalicSystemFontMethod = class_getClassMethod(self, #selector(applicationItalicSystemFont(ofSize:))) {
            method_exchangeImplementations(italicSystemFontMethod, applicationItalicSystemFontMethod)
        }
        
        // Initializer from coder
        if let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))), // Trick to get over the lack of UIFont.init(coder:))
            let applicationInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(applicationCoder:))) {
            method_exchangeImplementations(initCoderMethod, applicationInitCoderMethod)
        }
        
    }
    
    // MARK: Initialization
    
    /// Swizzled initializer from decoder.
    @objc
    convenience init(applicationCoder aDecoder: NSCoder) {
        
        guard
            let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor,
            let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String
            else { self.init(applicationCoder: aDecoder); return }

        let fontName: String = {
            switch fontAttribute {
            case "CTFontRegularUsage":
                return applicationSystemFontName
            case "CTFontEmphasizedUsage", "CTFontBoldUsage":
                return applicationBoldSystemFontName
            case "CTFontObliqueUsage":
                return applicationItalicSystemFontName
            default:
                return applicationSystemFontName
            }
        }()
        
        self.init(name: fontName, size: fontDescriptor.pointSize)!
        
    }
    
    // MARK: Properties
    
    /// Returns a bold copy of this font, if one exists.
    var boldFont: UIFont? {
        var symbolicTraits = fontDescriptor.symbolicTraits
        symbolicTraits.insert(.traitBold)
        return withSymbolicTraits(symbolicTraits)
    }
    
    /// Returns an italic copy of this font, if one exists.
    var italicFont: UIFont? {
        var symbolicTraits = fontDescriptor.symbolicTraits
        symbolicTraits.insert(.traitItalic)
        return withSymbolicTraits(symbolicTraits)
    }
 
    /// Returns a copy of this font with the specified symbolic traits, if possible.
    func withSymbolicTraits(_ symbolicTraits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        guard let descriptor = fontDescriptor.withSymbolicTraits(symbolicTraits) else { return nil }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
}
