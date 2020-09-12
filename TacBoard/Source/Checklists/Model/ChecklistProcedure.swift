//
//  ChecklistProcedure.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/1/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift

// MARK: - ChecklistDataIndex

/// Type representing a data index of checklist procedures.
typealias ChecklistDataIndex = DataIndex<ChecklistBinder>

extension DataIndex where Object: ChecklistBinder {
    
    // MARK: Class Methods
    
    /// The embedded fallback checklist data index.
    static var fallback: ChecklistDataIndex {
        return ChecklistDataIndex.load(localURL: ContentManager.url(forRelativePath: relativePath, source: .fallback))
    }
    
    /// Asynchronously loads the checklist index from the specified content manager.
    /// - note: The completion block is guaranteed to be called on the main thread.
    static func load(source: ContentSource, completion: @escaping (ChecklistDataIndex?) -> Void) {
        ChecklistDataIndex.load(url: ContentManager.url(forRelativePath: relativePath, source: source), completion: completion)
    }
    
    // MARK: Private Utility
    
    /// The expected relative path for the checklist index.
    private static var relativePath: String { return "ChecklistDataIndex.json" }
    
}

// MARK: - ChecklistBinder

/// Type representing a binder of checklist procedures.
typealias ChecklistBinder = Binder<ChecklistProcedure>

extension Binder where Item == ChecklistProcedure {
    
    // MARK: Methods
    
    /// Sets the `isComplete` status for all procedures contained in this binder.
    func setIsComplete(_ isComplete: Bool) {
        for folder in folders {
            folder.setIsComplete(isComplete)
        }
    }
    
}

// MARK: - ChecklistFolder

/// Type representing a folder of checklist procedures.
typealias ChecklistFolder = Folder<ChecklistProcedure>

extension Folder where Item: ChecklistProcedure {
 
    // MARK: Methods
    
    /// Sets the `isComplete` status for all procedures contained in this folder and its subfolders.
    func setIsComplete(_ isComplete: Bool) {
     
        // Update all procedures
        for procedure in items {
            procedure.setIsComplete(isComplete)
        }
        
        // Recursively update all folders
        for folder in subfolders {
            folder.setIsComplete(isComplete)
        }
        
    }
    
}

// MARK: - ChecklistProcedure

/// Object representing a single procedure in a checklist.
class ChecklistProcedure: Decodable, ReferenceEquatable {
    
    // MARK: Initialization
    
    /// Initializes a new instance with the specified values.
    init(title: String, subtitle: String? = nil, sections: [ChecklistSection] = []) {
        self.title = title
        self.subtitle = subtitle
        self.sections = sections
        self.isComplete = Property(initial: false, then: sections.isCompletedProducer)
    }
    
    // MARK: Properties
    
    /// The title of the procedure.
    let title: String
    
    /// The subtitle of the procedure, if any.
    let subtitle: String?
    
    /// The sections contained in this procedure.
    let sections: [ChecklistSection]
    
    /// If set to `true`, all items in this checklist procedure have been completed.
    let isComplete: Property<Bool>
    
    // MARK: Methods
    
    /// Sets the `isComplete` state for this procedure.
    func setIsComplete(_ isComplete: Bool) {
        for section in sections {
            for item in section.items {
                guard
                    let completableItem = item as? ChecklistCompletableItem,
                    completableItem.isComplete.value != isComplete
                    else { continue }
                completableItem.isComplete.value = isComplete
            }
        }
    }
    
    // MARK: Codable
    
    /// `CodingKey` enum for this class.
    private enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case sections
    }
    
    /// Initializes a new instance with the specified `Decoder`.
    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(title: try container.decode(String.self, forKey: .title),
                  subtitle: try container.decodeOrDefault(String?.self, forKey: .subtitle, default: nil),
                  sections: try container.decodeOrDefault([ChecklistSection].self, forKey: .sections, default: []))
    }
    
}

fileprivate extension Array where Element: ChecklistSection {

    /// Returns a `SignalProducer<Bool, Never>` if all `ChecklistCompletableItem`s in this array are set to complete.
    var isCompletedProducer: SignalProducer<Bool, Never> {
        let items: [ChecklistCompletableItem] = reduce([]) { $0 + $1.items.compactMap { $0 as? ChecklistCompletableItem } }
        return SignalProducer.combineLatest(items.map { $0.isComplete.producer }).map { $0.allSatisfy { $0 } }
    }
    
}
