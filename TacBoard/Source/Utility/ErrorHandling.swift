//
//  ErrorHandling.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

// MARK: - Functions

/// Fails the application with a `fatalError()`.
/// - note: This is intended to be used when an invalid index path is specified.
func fatalInvalidIndexPath() -> Never {
    fatalError("Invalid index path!")
}

/// Fails the application with a `fatalError()`.
/// - note: This is intended to be called when a required resource is missing or invalid.
func fatalInvalidResource() -> Never {
    fatalError("Invalid resource!")
}

/// Fails the application with a `fatalError()`.
/// - note: This is intended to be called when a segue is invalid.
func fatalInvalidSegue() -> Never {
    fatalError("Invalid segue!")
}

/// Fails the application with a `fatalError()`.
/// - note: This is intended to be called when a non-available function is called.
func fatalNotAvailable() -> Never {
    fatalError("Not available!")
}

/// Fails the application with a `fatalError()`.
/// - note: This is intended to be called when a subclass must implement a function.
func fatalSubclassMustImplement() -> Never {
    fatalError("Subclass must implement!")
}
