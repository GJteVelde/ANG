//
//  ActivityDetailTableViewController.swift
//  ANG
//
//  Created by Gerjan te Velde on 17/02/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class ActivityDetailTableViewController: UITableViewController {

    //MARK: - Objects and properties
    @IBOutlet var titleLabel: UILabel!
    
    var selectedActivity: Activity!
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedActivity = selectedActivity {
            titleLabel.text = selectedActivity.title
        }
    }
}
