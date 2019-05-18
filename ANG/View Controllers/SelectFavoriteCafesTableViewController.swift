//
//  SelectFavoriteCafesTableViewController.swift
//  ANG
//
//  Created by Gerjan te Velde on 18/05/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import CloudKit

class SelectFavoriteCafesTableViewController: UITableViewController {
    
    //MARK: - Objects and Properties
    var cloudKitService: CloudKitService!
    
    var favoriteCafesWithIds = [Cafe.RecordId: String]()
    var favoriteCafes = [Cafe]()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cloudKitService = CloudKitService.default
        navigationItem.title = "Favoriete cafés"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadFavoriteCafes()
    }
    
    //MARK: - Table View Data Source Methods
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Voeg nieuwe favoriete cafés toe via de kaart met cafés."
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteCafes.isEmpty ? 1 : favoriteCafes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CafeCell", for: indexPath)
        
        if favoriteCafes.isEmpty {
            cell.textLabel?.text = Cafe.returnFavoritesAsString()
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        let cafe = favoriteCafes[indexPath.row]
        
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
            cell.textLabel?.text = cafe.name
        }
        
        cell.tintColor = UIColor.angBlue
        
        return cell
    }
    
    //MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let cafe = favoriteCafes[indexPath.row]
        
        if cell.accessoryType == .none {
            cell.accessoryType = .checkmark
            cell.tintColor = UIColor.angBlue
            cafe.saveAsFavorite()
        } else if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            cafe.deleteAsFavorite()
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard cell.accessoryType == .detailButton else { return }
        
        let cafe = favoriteCafes[indexPath.row]
        
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
            
            switch result {
            case .failure(let error):
                let alert = UIAlertController(title: "Kon cafés niet laden", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Oké", style: .default))
                self.present(alert, animated: true)
            case .success(let fetchedCafes):
                self.favoriteCafes = fetchedCafes
                self.favoriteCafesWithIds = Cafe.loadFavorites()
                
                self.tableView.reloadData()
            }
        }
    }
}
