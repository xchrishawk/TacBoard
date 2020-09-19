//
//  AirportListTableViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/4/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import UIKit

/// `UITableViewController` subclass displaying terrain modules and their airports.
class AirportListTableViewController: TableViewController {

    // MARK: Fields
    
    private let viewModel: AirportViewModel
    
    @IBOutlet private var noAirportsView: UIView?
    @IBOutlet private var noAirportsLabel: UILabel?
    
    // MARK: Initialization
    
    /// Initializer not available.
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalNotAvailable() }

    /// Initializes a new instance with the specified coder and view model.
    init?(coder: NSCoder, viewModel: AirportViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    // MARK: UIViewController Overrides
    
    /// Initializes the view controller after the view loads.
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeBindings()
    }
    
    /// The active trait collection changed.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tableView.reloadData() // to add or remove chevrons as needed
    }
    
    // MARK: UITableViewDataSource
    
    /// Returns the number of sections to display.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.displayedCollections.value.count
    }
    
    /// Returns the title for the specified section.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return collection(at: section).terrainModule?.title ?? LocalizableString(.genericOther)
    }
    
    /// Returns the number of rows to display for the specified section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection(at: section).airports.count
    }
    
    /// Returns a cell for the row at the specified section.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AirportCell", for: indexPath) as! AirportTableViewCell
        let airport = self.airport(at: indexPath)
        
        cell.identifierLabel?.text = airport.identifier
        cell.nameLabel?.text = airport.name
        cell.countryFlagLabel?.text = airport.country.flag
        cell.callsignLabel?.text = airport.callsign
        cell.accessoryType = (traitCollection.horizontalSizeClass == .compact ? .disclosureIndicator : .none)
        
        return cell
        
    }
    
    // MARK: UITableViewDelegate
    
    /// The table view will display the specified cell.
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard traitCollection.horizontalSizeClass != .compact else { return }
        cell.isSelected = (airport(at: indexPath) === viewModel.selectedAirport.value)
    }
    
    /// The user selected the cell at the specified index path.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedAirport.value = airport(at: indexPath)
        if traitCollection.horizontalSizeClass == .compact {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            tableView.reloadData()
        }
    }
    
    /// The table is about to deselect the cell at the specified index path.
    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil // prevents user from manually deselecting selected rows
    }

    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
        
        // Reload the table view when the available data changes
        viewModel.displayedCollections.producer.take(duringLifetimeOf: self).startWithValues { [unowned self] _ in
            self.tableView.reloadData()
            self.noAirportsText = {
                guard self.viewModel.displayedCollections.value.isEmpty else { return nil }
                if self.viewModel.enabledTerrainModules.value.isEmpty {
                    return LocalizableString(.airportListEnableTerrainModule)
                } else {
                    return LocalizableString(.airportListNoMatches)
                }
            }()
        }
        
    }
    
    /// Returns the `AirportCollection` for the specified section index.
    private func collection(at section: Int) -> AirportCollection {
        return viewModel.displayedCollections.value[section]
    }
    
    /// Returns the `Airport` for the specified index path.
    private func airport(at indexPath: IndexPath) -> Airport {
        return collection(at: indexPath.section).airports[indexPath.row]
    }
    
    /// The "No Airports" explanation text to display.
    /// - note: If set to `nil`, the label will be hidden.
    private var noAirportsText: String? = nil {
        didSet {
            noAirportsLabel?.text = noAirportsText
            isNoAirportsViewHidden = noAirportsText.isNilOrEmpty
        }
    }
    
    /// If set to `true`, the "No Airports" view will be hidden.
    private var isNoAirportsViewHidden = true {
        didSet {
            
            guard
                isNoAirportsViewHidden != oldValue,
                let noAirportsView = noAirportsView
                else { return }
            
            if isNoAirportsViewHidden {
                
                // Hide view
                noAirportsView.removeFromSuperview()
                
            } else {
                
                // Show view
                view.addSubview(noAirportsView)
                noAirportsView.translatesAutoresizingMaskIntoConstraints = false
                noAirportsView.centerXAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerXAnchor).isActive = true
                noAirportsView.centerYAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerYAnchor).isActive = true
                noAirportsView.widthAnchor.constraint(lessThanOrEqualTo: tableView.safeAreaLayoutGuide.widthAnchor, constant: -20.0).isActive = true
                noAirportsView.sizeToFit()
                
            }
            
        }
    }
    
}
