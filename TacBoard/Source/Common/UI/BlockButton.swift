//
//  BlockButton.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/23/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// `UIButton` subclass accepting a block to be executed.
class BlockButton: UIButton {

    // MARK: Variables
    
    /// A block to be executed on the `.touchUpInside` event.
    var touchUpInside: (() -> Void)?
    
    // MARK: UIButton Overrides
    
    /// Configures the control after it is deserialized from the nib.
    override func awakeFromNib() {
        super.awakeFromNib()
        addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
    }
    
    // MARK: Actions
    
    /// Handler for the `.touchUpInside` event.
    @IBAction
    private func didTouchUpInside(_ sender: UIButton) {
        touchUpInside?()
    }
    
}
