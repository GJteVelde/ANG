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
        
        favoriteRegionLabel.text = Region.returnFavoritesAsString()
        favoriteCafeLabel.text = Cafe.returnFavoritesAsString()
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
