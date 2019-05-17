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
    case favoriteCafe
}

class SettingsTableViewController: UITableViewController {

    //MARK: - Objects and Properties
    @IBOutlet weak var favoriteRegionLabel: UILabel!
    @IBOutlet weak var favoriteCafeLabel: UILabel!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        favoriteRegionLabel.text = Region.returnLocallyFavoriteRegionsAsString()
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    //MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFavoriteRegionsSegue" {
            let destination = segue.destination as! SelectFavoritesTableViewController
            destination.favorite = .region
        } else if segue.identifier == "ShowFavoriteCafesSegue" {
            let destination = segue.destination as! SelectFavoritesTableViewController
            destination.favorite = .cafe
        }
    }
}
