//
//  SelectFavoriteCafesTableViewController.swift
//  ANG
//
//  Created by Gerjan te Velde on 18/05/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import CloudKit
import CoreLocation

class SelectFavoriteCafesTableViewController: UITableViewController {
    
    //MARK: - Objects and Properties
    var cloudKitService: CloudKitService!
    var locationManager: CLLocationManager!
    var filterButton: UIBarButtonItem!
    
    var headerTitle = ""
    
    var nearbyLocations = [Location]()
    
    var favoriteRegionsWithIds = [Region.RecordId: String]()
    var favoriteCafesWithIds = [Cafe.RecordId: String]()
    var cafes = [Cafe]()
    var countedCafes = NSCountedSet()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cloudKitService = CloudKitService.default
        
        navigationItem.title = "Favoriete cafés"
        filterButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterButtonTapped))
        navigationItem.rightBarButtonItem = filterButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resetData()
        favoriteCafesWithIds = Cafe.loadFavorites()
        
        
        
        loadFavoriteCafes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    //MARK: - Table View Data Source Methods
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitle
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cafes.isEmpty ? 1 : cafes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CafeCell", for: indexPath)
        
        if cafes.isEmpty {
            cell.textLabel?.text = Cafe.returnFavoritesAsString()
            cell.detailTextLabel?.text = nil
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        let cafe = cafes[indexPath.row]
        
        cell.isUserInteractionEnabled = true
        cell.tintColor = UIColor.angBlue
        cell.detailTextLabel?.text = nil
        
        if !nearbyLocations.isEmpty {
            var cafeLocations = [Location]()
            
            for location in cafe.locations {
                let locations = nearbyLocations.filter() { $0.recordId == location }
                cafeLocations += locations
            }
            
            if let currentLocation = locationManager.location {
                if cafeLocations.count == 1 {
                    let distanceInMeters = cafeLocations.first!.clLocation.distance(from: currentLocation)
                    cell.detailTextLabel?.text = "Huidige afstand: \(String(format: "%.1f", distanceInMeters / 1000)) kilometer."
                } else {
                    let cafeLocation = cafeLocations[countedCafes.count(for: cafe.name)]
                    
                    let distanceInMeters = cafeLocation.clLocation.distance(from: currentLocation)
                    cell.detailTextLabel?.text = "Huidige afstand: \(String(format: "%.1f", distanceInMeters / 1000)) kilometer, locatie \(cafeLocation.name)."
                    
                    countedCafes.add(cafe.name)
                }
            } else {
                print("currentLocation not available")
            }
        } else if !favoriteRegionsWithIds.isEmpty {
            if let favoriteRegionName = favoriteRegionsWithIds[cafe.region] {
                cell.detailTextLabel?.text = "Afdeling \(favoriteRegionName)"
            }
        }
        
        if cafe.isFavorite() {
            if cafe.name != favoriteCafesWithIds[cafe.recordId] {
                cell.textLabel?.text = favoriteCafesWithIds[cafe.recordId]
                cell.accessoryType = .detailButton
                cell.backgroundColor = UIColor.angYellow
            } else {
                cell.accessoryType = .checkmark
                cell.textLabel?.text = cafe.name
            }
        } else {
            cell.accessoryType = .none
            cell.textLabel?.text = cafe.name
        }
        
        return cell
    }
    
    //MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        
        let cafe = cafes[indexPath.row]
        
        if selectedCell.accessoryType == .none {
            selectedCell.accessoryType = .checkmark
            selectedCell.tintColor = UIColor.angBlue
            cafe.saveAsFavorite()
        } else if selectedCell.accessoryType == .checkmark {
            selectedCell.accessoryType = .none
            cafe.deleteAsFavorite()
        }
        
        for (index, value) in cafes.enumerated() where (value.name == cafe.name && index != indexPath.row) {
            guard let otherCell = tableView.cellForRow(at: IndexPath(row: index, section: indexPath.section)) else { return }
            
            if otherCell.accessoryType == .none {
                otherCell.accessoryType = .checkmark
            } else if otherCell.accessoryType == .checkmark {
                otherCell.accessoryType = .none
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard cell.accessoryType == .detailButton else { return }
        
        let cafe = cafes[indexPath.row]
        
        let nameOld = cell.textLabel!.text!
        let nameNew = cafe.name
        
        let alert = UIAlertController(title: "Naamswijziging", message: "Uw favoriete café '\(nameOld)' heeft een nieuwe naam gekregen: \(nameNew). De nieuwe naam wordt opgeslagen.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Oké", style: .default, handler: { (_) in
            cell.backgroundColor = .white
            cell.textLabel?.text = nameNew
            cell.accessoryType = .checkmark
            cafe.saveAsFavorite()
        }))
        present(alert, animated: true)
    }
    
    //MARK: - Methods
    func loadFavoriteCafes() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let favoriteCafeIds = Array(Cafe.loadFavorites().keys)
        
        cloudKitService.fetchCafesBasics(cafeIds: favoriteCafeIds) { [unowned self] (result) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.filterButton.isEnabled = true
            
            switch result {
            case .failure(let error):
                let alert = UIAlertController(title: "Kon cafés niet laden", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Oké", style: .default))
                self.present(alert, animated: true)
            case .success(let fetchedCafes):
                self.resetData()
                
                self.cafes = fetchedCafes
                self.favoriteCafesWithIds = Cafe.loadFavorites()
                
                self.headerTitle = "Mijn favoriete cafés"
                self.tableView.reloadData()
            }
        }
    }
    
    func loadNearbyLocations() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func fetchLocationsWithinRadius(inKm radius: CLLocationDistance, around location: CLLocation) {
        cloudKitService.fetchLocationsBasicsWithRadius(inKm: 30, around: location) { (result) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            switch result {
            case .failure(let error):
                self.filterButton.isEnabled = true
                let alert = UIAlertController(title: "Kon locaties niet laden", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Oké", style: .default))
                self.present(alert, animated: true)
            case .success(let fetchedLocations):
                self.loadNearbyCafes(ofLocations: fetchedLocations)
            }
        }
    }
    
    func loadNearbyCafes(ofLocations locations: [Location]) {
        if locations.isEmpty {
            filterButton.isEnabled = true
            let alert = UIAlertController(title: "Geen cafés in de buurt", message: "Er werden binnen de door u geselecteerde straal geen cafés gevonden.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Oké", style: .default))
            present(alert, animated: true)
        } else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            cloudKitService.fetchCafesBasicsAtLocations(locations) { (result) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.filterButton.isEnabled = true
                
                switch result {
                case .failure(let error):
                    let alert = UIAlertController(title: "Kon cafés niet laden", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Oké", style: .default))
                    self.present(alert, animated: true)
                case .success(let fetchedCafes):
                    self.resetData()
                    self.nearbyLocations = locations
                    
                    for location in locations {
                        for cafe in fetchedCafes {
                            if cafe.locations.contains(location.recordId) {
                                self.cafes.append(cafe)
                            }
                        }
                    }
                    
                    self.headerTitle = "Cafés in de buurt"
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func loadCafesOfFavoriteRegions() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        favoriteRegionsWithIds = Region.loadFavorites()
        let favoriteRegionsId = Array(favoriteRegionsWithIds.keys)
        
        cloudKitService.fetchCafesBasicsInRegions(favoriteRegionsId) { [unowned self] (result) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.filterButton.isEnabled = true
            
            switch result {
            case .failure(let error):
                let alert = UIAlertController(title: "Kon cafés niet laden", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Oké", style: .default))
                self.present(alert, animated: true)
            case .success(let cafesResult):
                self.resetData()
                
                self.favoriteRegionsWithIds = Region.loadFavorites()
                self.favoriteCafesWithIds = Cafe.loadFavorites()
                self.cafes = cafesResult
                
                self.headerTitle = "Cafés van favoriete afdelingen"
                self.tableView.reloadData()
            }
        }
    }
    
    func loadAllCafes() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        cloudKitService.fetchAllCafesBasics { [unowned self] (result) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.filterButton.isEnabled = true
            
            switch result {
            case .failure(let error):
                let alert = UIAlertController(title: "Kon cafés niet laden", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Oké", style: .default))
                self.present(alert, animated: true)
            case .success(let cafesResult):
                self.resetData()
                
                self.cafes = cafesResult
                
                self.headerTitle = "Alle cafés"
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func filterButtonTapped(_ sender: UIBarButtonItem) {
        favoriteCafesWithIds = Cafe.loadFavorites()
        
        let actionSheet = UIAlertController(title: "Selecteer een filter", message: nil, preferredStyle: .actionSheet)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        
        actionSheet.addAction(UIAlertAction(title: "Mijn favoriete cafés", style: .default, handler: { [unowned self] (_) in
            self.filterButton.isEnabled = false
            self.loadFavoriteCafes()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cafés in mijn buurt", style: .default, handler: { [unowned self] (_) in
            self.filterButton.isEnabled = false
            self.loadNearbyLocations()
        }))
        
        if !Region.loadFavorites().isEmpty {
            actionSheet.addAction(UIAlertAction(title: "Cafés van favoriete afdelingen", style: .default, handler: { [unowned self] (_) in
                self.filterButton.isEnabled = false
                self.loadCafesOfFavoriteRegions()
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Alle cafés", style: .default, handler: { [unowned self] (_) in
            self.filterButton.isEnabled = false
            self.loadAllCafes()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Annuleer", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    func resetData() {
        nearbyLocations.removeAll(keepingCapacity: true)
        favoriteRegionsWithIds.removeAll(keepingCapacity: true)
        cafes.removeAll(keepingCapacity: true)
        countedCafes.removeAllObjects()
    }
    
}

//MARK: -
extension SelectFavoriteCafesTableViewController: CLLocationManagerDelegate {
    //MARK: Location Manager Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        let location = locations.first!
        
        let actionSheet = UIAlertController(title: "Cafés binnen een straal van", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "10 kilometer", style: .default, handler: { (_) in
            self.fetchLocationsWithinRadius(inKm: 10, around: location)
        }))
        actionSheet.addAction(UIAlertAction(title: "25 kilometer", style: .default, handler: { (_) in
            self.fetchLocationsWithinRadius(inKm: 25, around: location)
        }))
        actionSheet.addAction(UIAlertAction(title: "50 kilometer", style: .default, handler: { (_) in
            self.fetchLocationsWithinRadius(inKm: 50, around: location)
        }))
        actionSheet.addAction(UIAlertAction(title: "Annuleer", style: .cancel, handler: { (_) in
            self.filterButton.isEnabled = true
        }))
        
        present(actionSheet, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        guard let clError = error as? CLError else { return }
        print(clError)
        
        switch clError.code {
        case .locationUnknown:
            print("clError: location unknown.")
        case .denied:
            filterButton.isEnabled = true
            let alert = UIAlertController(title: "Kon locatie niet ophalen", message: "Geef toegang tot uw locatie via Instellingen om cafés in de buurt te kunnen zien en probeer het opnieuw.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Instellingen", style: .default, handler: { (_) in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Oké", style: .default))
            
            present(alert, animated: true)
        default:
            filterButton.isEnabled = true
            let alert = UIAlertController(title: "Kon locatie niet ophalen", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Oké", style: .default))
            present(alert, animated: true)
        }
    }
}
