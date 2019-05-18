//
//  SelectRegionsTableViewController.swift
//  ANG
//
//  Created by Gerjan te Velde on 10/05/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class SelectFavoriteRegionsTableViewController: UITableViewController {
    
    //MARK: - Objects and Properties
    var cloudKitService: CloudKitService!
    
    var favoriteRegions = [Region.RecordId: String]()
    var regions = [Region.Province: [Region]]()
    var provinces = [Region.Province]()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cloudKitService = CloudKitService.default
        favoriteRegions = Region.loadFavorites()
        
        loadAllRegions()
        
        navigationItem.title = "Favoriete afdelingen"
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
        return "Provincie \(provinces[section].rawValue)"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegionCell", for: indexPath)
        cell.tintColor = UIColor.angBlue
        
        let province = provinces[indexPath.section]
        let region = regions[province]![indexPath.row]
        
        if region.isFavorite() {
            if region.name != favoriteRegions[region.recordId] {
                cell.textLabel?.text = favoriteRegions[region.recordId]
                cell.accessoryType = .detailButton
                cell.backgroundColor = UIColor.angYellow
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
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let province = provinces[indexPath.section]
        let region = regions[province]![indexPath.row]
        
        if cell.accessoryType == .none {
            cell.accessoryType = .checkmark
            cell.tintColor = UIColor.angBlue
            region.saveAsFavorite()
        } else if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            region.deleteAsFavorite()
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let province = provinces[indexPath.section]
        let region = regions[province]![indexPath.row]
        
        let nameOld = cell.textLabel!.text!
        let nameNew = region.name
        
        let alert = UIAlertController(title: "Naamswijziging", message: "Uw favoriete afdeling '\(nameOld)' heeft een nieuwe naam gekregen: \(nameNew). De nieuwe naam wordt opgeslagen.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Oké", style: .default, handler: { (_) in
            cell.backgroundColor = .white
            cell.textLabel?.text = nameNew
            cell.accessoryType = .checkmark
            region.saveAsFavorite()
        }))
        present(alert, animated: true)
    }
    
    //MARK: - Methods
    func loadAllRegions() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var regionsUnsorted = [Region.Province: [Region]]()
        
        cloudKitService.fetchAllRegions { [unowned self] (result) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            switch result {
            case .failure(let resultError):
                print(resultError.localizedDescription)
                
                let alert = UIAlertController(title: "Kon afdelingen niet laden", message: resultError.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Oké", style: .default))
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
            }
        }
    }
}
