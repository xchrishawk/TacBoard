//
//  AirportDetailViewController.swift
//  TacBoard
//
//  Created by Vig, Christopher on 8/4/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

import Foundation
import ReactiveSwift
import UIKit

/// `UITableViewController` subclass displaying details for a specific airport.
class AirportDetailViewController: TableViewController, SplitDisplayModeTogglingViewController {
    
    // MARK: Types
    
    /// Struct representing a section to display in the table view.
    private struct Section {
        
        /// The title of the section.
        let title: String
        
        /// The items to display in the section.
        let items: [Item]
        
    }
    
    /// Enumeration of items which may be displayed.
    private enum Item {
        
        // MARK: Cases
        
        /// Displays the airport identifier.
        case identifier(_: String)
        
        /// Displays the airport name and local name.
        case name(_: String, unlocalized: String?)
        
        /// Displays the airport callsign.
        case callsign(_: String)
        
        /// Displays the airport type.
        case type(_: AirportType)
        
        /// Displays the airport's city.
        case city(_: String?)
        
        /// Displays the airport's country.
        case country(_: ISO3166)
        
        /// Displays the latitude/longitude of the airport.
        case latLon(_: LatLon)
        
        /// Displays the elevation of the airport.
        case elevation(_: Measurement<UnitLength>)
        
        /// Displays the magnetic variation of the airport.
        case magneticVariation(_: Measurement<UnitAngle>)
        
        /// Displays a link to an airport image.
        case image(_: AirportImage)
        
        /// Displays navaid information.
        case navaid(_: AirportNavaid)
        
        /// Displays frequency information.
        case frequency(_: AirportCommFrequency)
        
        /// Displays a runway.
        case runway(_: AirportRunway)
        
    }

    // MARK: Fields
    
    private let viewModel: AirportViewModel
    private let airport: Airport
    private let displayFormatter: DisplayFormatter
    
    /// The sections to display.
    private lazy var sections: [Section] = {
       
        var sections: [Section] = []
        
        /// Appends a section to the list.
        func append(title: String, items: [Item]) {
            guard !items.isEmpty else { return }
            sections.append(Section(title: title, items: items))
        }
        
        // Basic information section
        var informationItems: [Item] = []
        informationItems.append(.identifier(airport.identifier))
        informationItems.append(.name(airport.name, unlocalized: airport.unlocalizedName))
        if let callsign = airport.callsign {
            informationItems.append(.callsign(callsign))
        }
        informationItems.append(.type(airport.type))
        append(title: LocalizableString(.airportDetailSectionInformation), items: informationItems)
        
        // Location section
        var locationItems: [Item] = []
        locationItems.append(.city(airport.city))
        locationItems.append(.country(airport.country))
        locationItems.append(.latLon(airport.latLon))
        locationItems.append(.elevation(airport.elevation))
        locationItems.append(.magneticVariation(airport.magneticVariation))
        append(title: LocalizableString(.airportDetailSectionLocation), items: locationItems)
        
        // Images section
        let imageItems: [Item] = airport.images.map { .image($0) }
        append(title: LocalizableString(.airportDetailSectionImages), items: imageItems)
        
        // Navigation section
        var navigationItems: [Item] = []
        navigationItems.append(contentsOf: airport.navaids.map { .navaid($0) })
        append(title: LocalizableString(.airportDetailSectionNavigation), items: navigationItems)
        
        // Communications section
        var communicationsItems: [Item] = []
        communicationsItems.append(contentsOf: airport.frequencies.map { .frequency($0) })
        append(title: LocalizableString(.airportDetailSectionCommunications), items: communicationsItems)
        
        // Runways section
        let runwayItems: [Item] = airport.runways.map { .runway($0) }
        append(title: LocalizableString(.airportDetailSectionRunways), items: runwayItems)
        
        return sections
        
    }()
    
    // MARK: Outlets
    
    @IBOutlet var splitDisplayModeBarButtonItem: UIBarButtonItem? // needs to be non-private for SplitDisplayModeTogglingViewController conformance
    
    // MARK: Initialization

    /// Initializer not available.
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalNotAvailable() }
    
    /// Initializes a new instance with the specified coder, view model, and airport.
    init?(coder: NSCoder,
          viewModel: AirportViewModel,
          airport: Airport,
          displayFormatter: DisplayFormatter = DisplayFormatter.shared) {
        
        self.viewModel = viewModel
        self.airport = airport
        self.displayFormatter = displayFormatter
        
        super.init(coder: coder)
        
    }
    
    // MARK: UIViewController Overrides
    
    /// Initializes the view controller after the view has loaded.
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.title = airport.name
        updateIsSplitDisplayModeButtonHidden()
        
        initializeBindings()
        
    }
    
    /// The view will transition to a new size.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateIsSplitDisplayModeButtonHidden(coordinator: coordinator)
    }
    
    /// The view will transition to a new trait collection.
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updateIsSplitDisplayModeButtonHidden(with: newCollection, coordinator: coordinator)
    }
    
    /// The view transitioned to a new trait collection.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    
    /// Returns the number of sections to display.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    /// Returns the title for the section at the specified index.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section(at: section).title
    }
    
    /// Returns the number of rows to display in the specified section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.section(at: section).items.count
    }
    
    /// Returns a cell for the row at the specified index.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! AirportDetailTableViewCell
        let item = self.item(at: indexPath)
        
        /// Displays and sets the text of the title label.
        func setTitle(_ text: String?) {
            cell.titleLabel?.text = text
            cell.titleLabel?.safeIsHidden = text.isNilOrEmpty
        }
        
        /// Displays and sets the text of the first (i.e., top) data label.
        func setData1(_ text: String?, color: ApplicationColor = .primaryText) {
            cell.data1Label?.text = text
            cell.data1Label?.textColor = UIColor(application: color)
            cell.data1Label?.safeIsHidden = text.isNilOrEmpty
        }
        
        /// Displays and sets the text of the second (i.e., bottom) data label.
        func setData2(_ text: String?, color: ApplicationColor = .primaryText) {
            cell.data2Label?.text = text
            cell.data2Label?.textColor = UIColor(application: color)
            cell.data2Label?.safeIsHidden = text.isNilOrEmpty
        }
        
        /// Displays and sets the text of the first (i.e., top) auxiliary label.
        func setAuxiliaryData1(_ text: String?, color: ApplicationColor = .primaryText) {
            cell.auxiliaryDataView?.safeIsHidden = false
            cell.auxiliaryData1Label?.text = text
            cell.auxiliaryData1Label?.textColor = UIColor(application: color)
            cell.auxiliaryData1Label?.safeIsHidden = false
        }
        
        /// Displays and sets the text of the second (i.e., bottom) auxiliary label.
        func setAuxiliaryData2(_ text: String?, color: ApplicationColor = .primaryText) {
            cell.auxiliaryDataView?.safeIsHidden = false
            cell.auxiliaryData2Label?.text = text
            cell.auxiliaryData2Label?.textColor = UIColor(application: color)
            cell.auxiliaryData2Label?.safeIsHidden = false
        }
        
        /// Displays and sets the text of the placeholder label.
        func setPlaceholder(_ text: String?) {
            cell.placeholderLabel?.text = text
            cell.placeholderLabel?.safeIsHidden = text.isNilOrEmpty
        }
        
        // Configure the cell based on the item in question
        switch item {
            
        case .identifier(let identifier):
            setTitle(LocalizableString(.airportDetailItemIdentifier))
            setData1(identifier)
            
        case .name(let name, let unlocalizedName):
            setTitle(LocalizableString(.airportDetailItemName))
            setData1(name)
            setData2(unlocalizedName)
            
        case .callsign(let callsign):
            setTitle(LocalizableString(.airportDetailItemCallsign))
            setData1(callsign)
            
        case .type(let type):
            setTitle(LocalizableString(.airportDetailItemType))
            setData1(String(describing: type))
            
        case .city(let city):
            setTitle(LocalizableString(.airportDetailItemCity))
            if let city = city {
                setData1(city)
            } else {
                setPlaceholder(LocalizableString(.genericNA))
            }
            
        case .country(let country):
            setTitle(LocalizableString(.airportDetailItemCountry))
            setData1("\(country.flag) \(country.name)")
            
        case .latLon(let latLon):
            setTitle(LocalizableString(.airportDetailItemLatLon))
            setData1("\(displayFormatter.string(forLatitude: latLon.latitude, format: viewModel.latLonFormat.value))")
            setData2("\(displayFormatter.string(forLongitude: latLon.longitude, format: viewModel.latLonFormat.value))") // TODO
            
        case .elevation(let elevation):
            setTitle(LocalizableString(.airportDetailItemElevation))
            setData1(displayFormatter.string(for: elevation, displayUnit: displayUnitForDimensions))
            
        case .magneticVariation(let magneticVariation):
            setTitle(LocalizableString(.airportDetailItemMagneticVariation))
            setData1(displayFormatter.string(forMagneticVariation: magneticVariation))
                
        case .image(let image):
            setTitle(traitCollection.horizontalSizeClass == .compact ? image.compactTitle : image.title) // assumed to be localized
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            
        case .navaid(let navaid):
            switch navaid.type {
                
            case .ILS:
                setTitle("\(navaid.type.description) \(LocalizableString(.genericRunway)) \(navaid.runwayIdentifier ?? LocalizableString(.genericNA))")
                setData1(displayFormatter.string(for: navaid.frequency, displayUnit: .megahertz, minimumFractionDigits: 2))
                setData2("\(navaid.identifier ?? LocalizableString(.genericNA)) \(LocalizableString(.genericSlashSeparator)) \(displayFormatter.string(for: navaid.heading))", color: .secondaryText)
                
            case .RSBN, .PRMG:
                setTitle("\(navaid.type.description) \(LocalizableString(.genericRunway)) \(navaid.runwayIdentifier ?? LocalizableString(.genericNA))")
                setData1(displayFormatter.string(for: navaid.frequency, displayUnit: .megahertz, minimumFractionDigits: 2))
                setData2("\(navaid.identifier ?? LocalizableString(.genericNA)) \(LocalizableString(.genericSlashSeparator)) \(LocalizableString(.genericChannel)) \(navaid.channel ?? LocalizableString(.genericNA)) \(LocalizableString(.genericSlashSeparator)) \(displayFormatter.string(for: navaid.heading))", color: .secondaryText)
                
            case .TACAN:
                setTitle("\(navaid.type.description)")
                setData1("\(LocalizableString(.genericChannel)) \(navaid.channel ?? LocalizableString(.genericNA))")
                setData2("\(navaid.identifier ?? LocalizableString(.genericNA))", color: .secondaryText)
                 
            case .VORTAC:
                setTitle("\(navaid.type.description)")
                setData1("\(LocalizableString(.genericChannel)) \(navaid.channel ?? LocalizableString(.genericNA))")
                setData2("\(navaid.identifier ?? LocalizableString(.genericNA)) \(LocalizableString(.genericSlashSeparator)) \(displayFormatter.string(for: navaid.frequency, displayUnit: .megahertz, minimumFractionDigits: 2))", color: .secondaryText)
                
            case .VOR, .VORDME:
                setTitle("\(navaid.type.description)")
                setData1(displayFormatter.string(for: navaid.frequency, displayUnit: .megahertz, minimumFractionDigits: 2))
                setData2("\(navaid.identifier ?? LocalizableString(.genericNA))", color: .secondaryText)
                
            case .NDB:
                setTitle("\(navaid.type.description)")
                setData1("\(displayFormatter.string(for: navaid.frequency, displayUnit: .kilohertz, maximumFractionDigits: 0))")
                setData2("\(navaid.identifier ?? LocalizableString(.genericNA))", color: .secondaryText)
                
            default:
                break // TODO
                
            }
            
            // Display off field data if needed
            if let (offFieldHeading, offFieldDistance) = navaid.offField {
                setAuxiliaryData1("Off Field", color: .secondaryText)
                setAuxiliaryData2("\(displayFormatter.string(for: offFieldHeading)) @ \(displayFormatter.string(for: offFieldDistance))", color: .secondaryText)
            }
            
        case .frequency(let frequency):
            setTitle(frequency.title) // assumed to be localized
            setData1(displayFormatter.string(for: frequency.frequency, displayUnit: .megahertz, minimumFractionDigits: 3))
            setData2("\(String(describing: frequency.band)) / \(String(describing: frequency.modulation))", color: .secondaryText)
            
        case .runway(let runway):
            setTitle("\(LocalizableString(.genericRunway)) \(runway.identifier) \(LocalizableString(.genericSlashSeparator)) \(runway.reciprocalIdentifier)")
            setData1("\(displayFormatter.string(for: runway.length, displayUnit: displayUnitForDimensions)) " +
                "\(LocalizableString(.genericXSeparator)) " +
                "\(displayFormatter.string(for: runway.width, displayUnit: displayUnitForDimensions))")
            setData2("\(displayFormatter.string(for: runway.heading)) " +
                "\(LocalizableString(.genericSlashSeparator)) " +
                "\(displayFormatter.string(for: runway.reciprocalHeading))", color: .secondaryText)
            
        }
        
        return cell
        
    }
    
    // MARK: UITableViewDelegate
    
    /// The user selected the row at the specified index path.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = self.item(at: indexPath)
        switch item {
        case .image(let image):
            performSegue(withIdentifier: "ShowImage", sender: image)
        default:
            break
        }
        
    }
    
    // MARK: Segue Actions
    
    /// Creates a `MediaFrameViewController` for displaying an airport image.
    @IBSegueAction
    private func createMediaFrameViewController(_ coder: NSCoder, sender: Any?) -> UIViewController? {
        
        // Get the image we are going to display
        guard let airportImage = sender as? AirportImage else { fatalInvalidSegue() }
        
        // Create the scrollable content view controller
        let airportImageViewController: AirportImageViewController = UIStoryboard.App.airports.instantiateViewController(identifier: "AirportImage") { coder in
            return AirportImageViewController(coder: coder, viewModel: self.viewModel, airport: self.airport, airportImage: airportImage)
        }
        
        // Return the media frame controller with the content embedded
        return MediaFrameViewController(coder: coder,
                                        content: airportImageViewController,
                                        splitDisplayMode: viewModel.splitDisplayMode,
                                        darkModeBrightness: viewModel.darkModeBrightness,
                                        title: (traitCollection.horizontalSizeClass == .compact ? airportImage.compactTitle : airportImage.title),
                                        credit: airportImage.credit,
                                        disclaimer: LocalizableString(.airportChartDisclaimer))
        
    }
    
    // MARK: Actions
    
    /// The user pressed the show/hide menu button.
    @IBAction
    private func splitDisplayModeBarButtonItemPressed(_ sender: UIBarButtonItem) {
        viewModel.splitDisplayMode.value.toggle()
    }
    
    // MARK: Private Utility
    
    /// Initializes ReactiveSwift bindings.
    private func initializeBindings() {
        
        // Reload the table view if display units change
        let producer = SignalProducer.combineLatest(viewModel.unitFormat.producer, viewModel.latLonFormat.producer)
        producer.take(duringLifetimeOf: self).startWithValues { [unowned self] _ in
            self.tableView.reloadData()
        }
        
    }
    
    /// Returns the `Section` at the specified index.
    private func section(at index: Int) -> Section {
        return sections[index]
    }
    
    /// Returns the `Item` at the specified index path.
    private func item(at indexPath: IndexPath) -> Item {
        return section(at: indexPath.section).items[indexPath.row]
    }
    
    /// The display unit to use for runway dimensions.
    private var displayUnitForDimensions: UnitLength {
        switch viewModel.unitFormat.value {
        case .imperial:
            return .feet
        case .metric:
            return .meters
        }
    }
    
}
