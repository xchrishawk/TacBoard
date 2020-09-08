//
//  UIView.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/9/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import UIKit

extension UIView {

    /// Sets `isHidden` if it is not equal to the current `isHidden`.
    var safeIsHidden: Bool {
        get { return isHidden }
        set {
            
            // WTF!
            // https://stackoverflow.com/a/56831635/434245
            guard newValue != isHidden else { return }
            isHidden = newValue
            
        }
    }
    
}

extension Reactive where Base: UIView {

    /// Binding target for `safeIsHidden`.
    var safeIsHidden: BindingTarget<Bool> {
        return makeBindingTarget { $0.safeIsHidden = $1 }
    }
    
}
