//
//  NSAttributedString.swift
//  TacBoard
//
//  Created by Chris Vig on 9/11/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {

    /// Initializes a new instance with the specified markup string.
    /// - todo: This could be spun off into a separate library??
    convenience init?(markup: String) {
        
        struct Local {
            static let regex = try! NSRegularExpression(pattern: "\\[(.+)\\](.*?)\\[\\/(?:\\1)\\]", options: [.dotMatchesLineSeparators])
        }

        let result = NSMutableAttributedString(string: markup)
        
        while true {
            
            // Find matching substrings in the current working result string
            let resultString = result.string
            guard let match = Local.regex.firstMatch(in: resultString, options: [], range: NSRange(location: 0, length: resultString.count)) else { break }
            
            let entireRange = match.range(at: 0)
            
            // Get the tag
            let tagRange = match.range(at: 1)
            let tag = (resultString as NSString).substring(with: tagRange)
            
            // Get the *attributed* content contained within the tag
            let contentRange = match.range(at: 2)
            let attributedContent = NSMutableAttributedString(attributedString: result.attributedSubstring(from: contentRange))
            
            /// Modifies the existing fonts in an attributed string
            func modifyFont(in attributedString: NSMutableAttributedString, updating: (UIFont?) -> UIFont) {
                
                // Get list of existing font ranges
                var fontRanges = [(UIFont, NSRange)]()
                attributedString.enumerateAttribute(.font, in: attributedString.range, options: []) { (value, range, _) in
                    guard let font = value as? UIFont else { return }
                    fontRanges.append((font, range))
                }
                
                // Apply the "baseline" font to the entire range
                attributedString.setAttributes([.font: updating(nil)], range: attributedString.range)
                
                // Now update all of the existing ranges as needed
                for (font, range) in fontRanges {
                    attributedString.setAttributes([.font: updating(font)], range: range)
                }
                
            }
            
            // Update the content attributed string based on the tag
            switch tag {
                
            case "b":
                modifyFont(in: attributedContent) { $0?.boldFont ?? UIFont.boldSystemFont(ofSize: Constants.defaultTextSize) }
                
            case "i":
                modifyFont(in: attributedContent) { $0?.italicFont ?? UIFont.italicSystemFont(ofSize: Constants.defaultTextSize) }
                
            case "large":
                modifyFont(in: attributedContent) { $0?.withSize(Constants.largeTextSize) ?? UIFont.systemFont(ofSize: Constants.largeTextSize) }
                
            case "small":
                modifyFont(in: attributedContent) { $0?.withSize(Constants.smallTextSize) ?? UIFont.systemFont(ofSize: Constants.smallTextSize) }
                
            case "verysmall":
                modifyFont(in: attributedContent) { $0?.withSize(Constants.verySmallTextSize) ?? UIFont.systemFont(ofSize: Constants.verySmallTextSize) }
                
            case "li":

                // Some things depend on whether or not we're at the beginning of the string...
                let isFirstLine = (entireRange.location == 0)
                
                // We need the attributes of the text. If the font is not set, then set it to
                // make sure that the bullet width is calculated correctly.
                var attributes = attributedContent.attributes(at: 0, effectiveRange: nil)
                if attributes[.font] == nil {
                    attributes[.font] = UIFont.systemFont(ofSize: Constants.defaultTextSize)
                }
                
                // Insert the bullet
                let bullet = "•  "
                attributedContent.insert(NSAttributedString(string: "\(isFirstLine ? "" : "\n")\(bullet)", attributes: attributes), at: 0)
                
                // Set up the paragraph style
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.firstLineHeadIndent = 0.0
                paragraphStyle.headIndent = (bullet as NSString).size(withAttributes: attributes).width
                paragraphStyle.paragraphSpacingBefore = (isFirstLine ? 0.0 : ((attributes[.font] as? UIFont)?.pointSize ?? Constants.defaultTextSize) * 0.75)
                attributedContent.addAttributes([.paragraphStyle: paragraphStyle], range: attributedContent.range)
                
            default:
                break
                
            }
            
            // Now replace the entire range with the updated attributed content
            result.replaceCharacters(in: entireRange, with: attributedContent)
            
        }
        
        self.init(attributedString: result)
        
    }
    
    // MARK: Properties
    
    /// Returns an `NSRange` covering the full range of this attributed string.
    var range: NSRange {
        return NSRange(location: 0, length: length)
    }
    
}
