//
//  UIImage.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/5/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import CoreImage
import Foundation
import UIKit

extension UIImage {

    /// Returns an inverted copy of this image.
    var inverted: UIImage? {
        
        guard
            let cgImage = cgImage,
            let filter = CIFilter(name: "CIColorInvert")
            else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard
            let result = filter.value(forKey: kCIOutputImageKey) as? CIImage
            else { return nil }
        
        return UIImage(ciImage: result, scale: scale, orientation: imageOrientation)
        
    }
    
}
