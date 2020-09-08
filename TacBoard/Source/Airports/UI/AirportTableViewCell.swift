//
//  AirportTableViewCell.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/4/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// Cell for displaying airports.
class AirportTableViewCell: SelectableHighlightableTableViewCell {

    /// The label for the airport's identifier.
    @IBOutlet var identifierLabel: UILabel?
    
    /// The label for the airport's name.
    @IBOutlet var nameLabel: UILabel?
    
    /// The label for the country flag emoji.
    @IBOutlet var countryFlagLabel: UILabel?
    
    /// The label for the airport's city.
    @IBOutlet var callsignLabel: UILabel?
    
}
