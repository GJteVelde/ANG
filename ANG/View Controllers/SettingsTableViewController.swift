//
//  SettingsTableViewController.swift
//  ANG
//
//  Created by Gerjan te Velde on 10/05/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

fileprivate enum SettingsSection: Int {
    case favoriteRegion
}

class SettingsTableViewController: UITableViewController {

    //MARK: - Objects and Properties
    var favoriteRegionsByName = [String]()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadFavoriteRegions()
        
        tableView.reloadRows(at: [IndexPath(row: 0, section: SettingsSection.favoriteRegion.rawValue)], with: .automatic)
    }
    
    //MARK: - Table View Data Source Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SettingsSection.favoriteRegion.rawValue {
            return 1
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SettingsSection.favoriteRegion.rawValue {
            return "Favoriete afdeling"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == SettingsSection.favoriteRegion.rawValue {
            return "Voor uw favoriete afdelingen zijn de gegevens altijd beschikbaar, ook wanneer u even niet verbonden bent met het internet. "
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        
        if indexPath == IndexPath(row: 0, section: SettingsSection.favoriteRegion.rawValue) {
            
            var cellText = ""
            if favoriteRegionsByName.count == 0 {
                cellText = "Er is nog geen favoriete afdeling geselecteerd."
            } else if favoriteRegionsByName.count == 1 {
                cellText = "Uw favoriete afdeling is \(favoriteRegionsByName.first!)."
            } else {
                var tempFavoriteRegionsByName = favoriteRegionsByName
                let lastRegion = tempFavoriteRegionsByName.removeLast()
                let favoriteRegionsString = tempFavoriteRegionsByName.joined(separator: ", ")
                cellText = "Uw favoriete afdelingen zijn \(favoriteRegionsString) en \(lastRegion)."
            }
            
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = cellText
        }
        
        return cell
    }
    
    //MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == IndexPath(row: 0, section: SettingsSection.favoriteRegion.rawValue) {
            performSegue(withIdentifier: "SelectFavoriteRegionSegue", sender: self)
        }
    }
    
    //MARK: - Methods
    func loadFavoriteRegions() {
        favoriteRegionsByName = Region.loadLocallyStoredFavoriteRegionsByIdName().values.sorted()
    }
}
