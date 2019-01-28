//
//  ActivitiesTableViewController.swift
//  ANG
//
//  Created by Gerjan te Velde on 28/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class ActivitiesTableViewController: UITableViewController {

    var activities: [Activity]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activities = Activities.all
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath)
        
        cell.textLabel?.text = activities[indexPath.row].title
        cell.detailTextLabel?.text = "\(activities[indexPath.row].cafe), \(activities[indexPath.row].location)"
        
        return cell
    }
}
