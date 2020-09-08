//
//  URL.swift
//  TacBoard
//
//  Created by Chris Vig on 8/31/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation

extension URL {

    /// Returns a copy of this URL minus the fragment, if any.
    func deletingFragment() -> URL? {
     
        // Get components from the URL.
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }

        // Delete the fragment and return the corresponding URL
        components.fragment = nil
        return components.url
        
    }
    
}
