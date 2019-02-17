//
//  ActivitiesTableViewController.swift
//  ANG
//
//  Created by Gerjan te Velde on 28/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class ActivitiesTableViewController: UITableViewController {

    var selectedCafe: Cafe!
    var activities: [Activity]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedCafe = selectedCafe {
            activities = Activities.ofCafe(selectedCafe.nameShort)
            title = selectedCafe.nameLong
        } else {
            activities = Activities.all
            title = "Activiteiten"
        }
    }

    //MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath)
        
        cell.textLabel?.text = activities[indexPath.row].title
        cell.detailTextLabel?.text = "\(activities[indexPath.row].cafe), \(activities[indexPath.row].location)"
        
        return cell
    }
    
    //MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ActivityDetailSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destination = segue.destination as! ActivityDetailTableViewController
                destination.selectedActivity = activities[indexPath.row]
            }
        }
    }
}
