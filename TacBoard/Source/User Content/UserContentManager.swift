//
//  UserContentManager.swift
//  TacBoard
//
//  Created by Chris Vig on 9/19/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift

// MARK: Types

/// Tuple representing a successfully parsed user content file.
typealias UserContent<T> = (url: URL, size: Int64?, object: T)

/// Tuple representing a user content file which could not be parsed.
typealias InvalidUserContent = (url: URL, size: Int64?, error: UserContentError)

/// Tuple representing an imported user checklist.
typealias UserChecklistDataIndex = UserContent<ChecklistDataIndex>

// MARK: - UserContentError

/// Enumeration of errors returned by `UserContentManager`.
enum UserContentError: Error {
 
    // MARK: Cases
    
    /// The file could not be imported.
    case importFailed(innerError: Error)
    
    /// The file is invalid and could not be loaded
    case invalidFile(innerError: Error)
    
    /// The file has an unrecognized extension.
    case unrecognizedPathExtension(pathExtension: String)
    
    // MARK: Properties
    
    /// Returns a description for this error.
    var localizedDescription: String {
        switch self {
        case .importFailed:
            return "The file could not be copied to the app directory."
        case .invalidFile:
            return "The file is in an invalid format and could not be loaded."
        case .unrecognizedPathExtension(let pathExtension):
            return "The file has an unrecognized file type: \(pathExtension)."
        }
    }
    
}

// MARK: - UserContentManager

/// Singleton class reponsible for managing user content.
class UserContentManager {
 
    // MARK: Fields
    
    private let queue: DispatchQueue
    private let userContentDirectoryURL: URL
    private let userContentDirectoryDispatchSource: DispatchSourceFileSystemObject
    
    private let (updatedSignal, updatedObserver) = Signal<Void, Never>.pipe()
    
    private let mutableChecklists: MutableProperty<[UserChecklistDataIndex]>
    private let mutableInvalids: MutableProperty<[InvalidUserContent]>

    private var skipUserContentDirectoryEvents: Int = 0
    private var pendingUserContentDirectoryEventWorkItem: DispatchWorkItem? = nil
    
    // MARK: Singleton / Initialization
    
    /// The shared instance of the `UserContentManager` class.
    static let shared = UserContentManager(userContentDirectoryURL: Constants.documentDirectoryURL)
    
    /// Initializes a new instance with the specified parameters.
    private init(userContentDirectoryURL: URL) {
        
        // Stored fields
        self.queue = DispatchQueue(label: "UserContentManager", qos: .default)
        self.userContentDirectoryURL = userContentDirectoryURL
        
        // Private mutable properties
        self.mutableChecklists = MutableProperty([])
        self.mutableInvalids = MutableProperty([])
        
        // Public immutable properties
        self.checklists = Property(self.mutableChecklists)
        self.invalids = Property(self.mutableInvalids)
        
        // Create dispatch source for monitoring file system changes
        // Since this is a singleton, we don't worry about cleanup
        let fd = open(userContentDirectoryURL.path, O_EVTONLY)
        self.userContentDirectoryDispatchSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: .write, queue: self.queue)
        self.userContentDirectoryDispatchSource.setEventHandler { [weak self] in
            self?.internalFileSystemEvent()
        }
        self.userContentDirectoryDispatchSource.resume()
        
        // Do an immediate scan for user content
        reloadContentNow()
        
    }
    
    // MARK: Properties
    
    /// `SignalProducer` sending a `Void` signal whenever the user content has been updated.
    /// - note: This signal fires immediately on subscription for consistency with other producers used by the app.
    var updated: SignalProducer<Void, Never> {
        
        let head = SignalProducer(value: ())
        let tail = SignalProducer(updatedSignal)
        
        return head.concat(tail)
        
    }
    
    /// The currently available user checklists.
    let checklists: Property<[UserChecklistDataIndex]>
    
    /// The list of URLs which could not be parsed, with their corresponding errors.
    let invalids: Property<[InvalidUserContent]>
    
    /// Returns the number of files being tracked by the user content manager.
    var count: Int {
        return (checklists.value.count + invalids.value.count)
    }
    
    // MARK: Methods
    
    /// Imports the user content file at the specified URL.
    /// - note: If there is already an existing file with the same name, it will be replaced.
    func importFile(at sourceURL: URL, completion: @escaping (Error?) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            do {
                
                let fm = FileManager.default
                
                // Delete the existing file, if present, ignoring errors
                let destinationURL = self.userContentDirectoryURL.appendingPathComponent(sourceURL.lastPathComponent)
                _ = try? fm.removeItem(at: destinationURL)
                
                // Now move the new file to the user content directory
                // Skip the corresponding file system event since we're going to do the processing here
                self.skipUserContentDirectoryEvents += 1
                try fm.moveItem(at: sourceURL, to: destinationURL)
                
                // Synchronously reload content
                let errors = self.internalReloadContentNow()
                
                // Call completion handler on main queue, notifying of any parse error that occurred
                DispatchQueue.main.async {
                    completion(errors[destinationURL])
                }
                
            } catch {
                
                // Report the error on the main queue
                DispatchQueue.main.async {
                    completion(UserContentError.importFailed(innerError: error))
                }
                
            }
        }
    }
    
    /// Scans the user content directory for user content files.
    func reloadContentNow() {
        queue.async { [weak self] in
            self?.internalReloadContentNow()
        }
    }
    
    // MARK: Private Utility
    
    /// A file system event was detected.
    /// - note: Must be called on the internal queue!
    private func internalFileSystemEvent() {

        // Make sure we don't need to skip this event
        guard skipUserContentDirectoryEvents == 0 else {
            skipUserContentDirectoryEvents = max(0, skipUserContentDirectoryEvents - 1)
            return
        }
        
        //
        // Issue #21
        //
        // When transferring checklist files through iTunes file transfer, it appears that the file system event
        // fires *before* the file is actually ready to be read. The result is that the file read fails the first time.
        //
        // To work around this, we add a short delay to allow the file system to get back into a good state before
        // attempting to read the file. If there was already a pending reload, then we cancel it and reschedule.
        //

        // Cancel the currently pending work item, if it exists
        pendingUserContentDirectoryEventWorkItem?.cancel()
        pendingUserContentDirectoryEventWorkItem = nil
        
        // Create a new work item and schedule it for execution after 0.5 seconds
        let item = DispatchWorkItem { [weak self] in self?.internalReloadContentNow() }
        queue.asyncAfter(deadline: .now() + .seconds(1), execute: item)
        pendingUserContentDirectoryEventWorkItem = item
        
    }
    
    /// Reloads content immediately.
    /// - note: Must be called on the internal queue!
    /// - returns: A `Dictionary` of failed `URL`s along with their corresponding errors.
    @discardableResult
    private func internalReloadContentNow() -> [URL: Error] {
        
        let fm = FileManager.default
        var checklists = [UserChecklistDataIndex]()
        var invalids = [InvalidUserContent]()
        var errors = [URL: Error]()
        
        // Loop through all available paths in the directory
        guard let filenames = fm.subpaths(atPath: userContentDirectoryURL.path) else { return [:] }
        for filename in filenames {

            // Skip anything that's a directory
            let url = userContentDirectoryURL.appendingPathComponent(filename)
            var isDirectory: ObjCBool = false
            if !fm.fileExists(atPath: url.path, isDirectory: &isDirectory) || isDirectory.boolValue { continue }
            
            // Get file size
            let size: Int64? = {
                guard
                    let attributes = try? fm.attributesOfItem(atPath: url.path),
                    let size = attributes[.size] as? Int64
                    else { return nil }
                return size
            }()

            // Check the file type
            if url.pathExtension.caseInsensitiveCompare("dcschecklist") == .orderedSame {
             
                // File is a checklist
                do {
                    
                    // Try to load the checklist
                    let index = try ChecklistDataIndex.loadSync(localURL: url)
                    let checklist: UserChecklistDataIndex = (url, size, index)
                    checklists.append(checklist)
                    
                } catch let innerError {
                 
                    // Failed to parse the checklist file
                    let error = UserContentError.invalidFile(innerError: innerError)
                    let invalid: InvalidUserContent = (url, size, error)
                    invalids.append(invalid)
                    errors[url] = error
                    
                }
                
            } else {
             
                // Unknown file type
                let error = UserContentError.unrecognizedPathExtension(pathExtension: url.pathExtension)
                let invalid: InvalidUserContent = (url, size, error)
                invalids.append(invalid)
                errors[url] = error
                
            }
            
        }
        
        // Jump back over to the main thread to update our properties
        DispatchQueue.main.async { [weak self] in
            
            // Update properties
            self?.mutableChecklists.value = checklists
            self?.mutableInvalids.value = invalids
            
            // Send the general "updated" signal
            self?.updatedObserver.send(value: ())
            
        }
        
        return errors
        
    }
    
}
