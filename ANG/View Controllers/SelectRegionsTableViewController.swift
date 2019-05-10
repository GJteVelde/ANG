//
//  SelectRegionsTableViewController.swift
//  ANG
//
//  Created by Gerjan te Velde on 10/05/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class SelectRegionsTableViewController: UITableViewController {

    //MARK: - Objects and Properties
    var cloudKitService: CloudKitService!
    
    var favoriteRegionsByIdName = [String: String]()
    var regions = [String: [Region]]()
    var provinces = [String]()
    
    var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cloudKitService = CloudKitService.default
        
        favoriteRegionsByIdName = Region.loadLocallyStoredFavoriteRegionsByIdName()
        loadAllRegions()
    }

    // MARK: - Table View Data Source Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return provinces.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let province = provinces[section]
        return regions[province]!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return provinces[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegionCell", for: indexPath)
        
        let province = provinces[indexPath.section]
        let region = regions[province]![indexPath.row]
        
        if favoriteRegionsByIdName.keys.contains(region.regionID.recordName) {
            if favoriteRegionsByIdName[region.regionID.recordName] != region.name {
                cell.textLabel?.text = favoriteRegionsByIdName[region.regionID.recordName]
                cell.accessoryType = .detailButton
                cell.backgroundColor = UIColor(red: 1, green: 165/255, blue: 0, alpha: 0.25)
            } else {
                cell.accessoryType = .checkmark
                cell.textLabel?.text = region.name
            }
        } else {
            cell.textLabel?.text = region.name
        }
        
        return cell
    }
    
    //MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //FIXME: Cells are not updated correctly.
        //Data, however, is stored correctly.
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let province = provinces[indexPath.section]
        let region = regions[province]![indexPath.row]
        
        if cell.accessoryType == .none {
            cell.accessoryType = .checkmark
            favoriteRegionsByIdName[region.regionID.recordName] = region.name
            Region.saveLocallyFavoriteRegionsByIdName(favoriteRegionsByIdName)
        } else if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            favoriteRegionsByIdName.removeValue(forKey: region.regionID.recordName)
            Region.saveLocallyFavoriteRegionsByIdName(favoriteRegionsByIdName)
        } else if cell.accessoryType == .detailButton {
            let nameOld = favoriteRegionsByIdName[region.regionID.recordName]!
            let nameNew = region.name
            
            let alert = UIAlertController(title: "Nieuwe naam", message: "Uw favoriete afdeling '\(nameOld)' heeft een nieuwe naam gekregen: \(nameNew).", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Oké", style: .default, handler: { [unowned self] (_) in
                cell.backgroundColor = .white
                cell.textLabel?.text = nameNew
                cell.accessoryType = .checkmark
                self.favoriteRegionsByIdName[region.regionID.recordName] = nameNew
                Region.saveLocallyFavoriteRegionsByIdName(self.favoriteRegionsByIdName)
            }))
            present(alert, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    //MARK: - Methods
    func loadAllRegions() {
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        var regionsUnsorted = [String: [Region]]()
            
        cloudKitService.fetchAllRegions { [unowned self] (result) in
            switch result {
            case .failure(let resultError):
                print(resultError.localizedDescription)
                
                let alert = UIAlertController(title: "Failed to fetch regions", message: resultError.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                
            case .success(let resultRegions):
                for region in resultRegions {
                    if regionsUnsorted.keys.contains(region.province) {
                        regionsUnsorted[region.province]!.append(region)
                    } else {
                        regionsUnsorted[region.province] = [region]
                    }
                }
                
                for (province, regions) in regionsUnsorted {
                    self.regions[province] = regions.sorted(by: <)
                }
                self.provinces = self.regions.keys.sorted()
                
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }
}
