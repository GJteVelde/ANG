//
//  CafeDetailTableViewController.swift
//  ANG
//
//  Created by Gerjan te Velde on 12/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import MapKit

class CafeDetailTableViewController: UITableViewController {
    
    //MARK: Properties
    var selectedCafe: String?
    var cafe: Cafe?
    var locations: [Location] = []
    var activities: [Activity] = []
    
    @IBOutlet weak var cafeLocationsMap: MKMapView!
    @IBOutlet weak var cafeLocationsLabel: UILabel!
    @IBOutlet var activityLabel: UILabel!
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Find and set cafe corresponding to selectedCafe
        if let selectedCafe = selectedCafe {
            if let cafe = Cafes.all[selectedCafe] {
                self.cafe = cafe
                print("CafeDetailTableVC: Cafe has been set: \(cafe)")
            }
        }
        
        //Find and set locations related to cafe
        if let cafeLocations = cafe?.locations {
            for cafeLocation in cafeLocations {
                if let location = Locations.all[cafeLocation] {
                    locations.append(location)
                    print("CafeDetailTableVC: New location has been added to locations: \(location.nameShort)")
                } else {
                    print("CafeDetailTableVC: Could not add new location to locations.")
                }
            }
        }
        
        //Show annotations of Cafe and center CafeMap
        if !locations.isEmpty {
            //TODO: Replace returnAnnotations(ofCafe) by (ofLocation)
            let locationAnnotations = AnnotatedLocation.returnAnnotations(of: locations)
            let region = AnnotatedLocation.centerMapAround(locationAnnotations)
            cafeLocationsMap.addAnnotations(locationAnnotations)
            cafeLocationsMap.setRegion(region, animated: true)
        } else {
            print("CafeDetailTableVC: Could not show location-annotation of \(selectedCafe ?? "unknown Cafe") on map.")
        }
        
        //Show location-details of Cafe in cafeLocationsLabel
        if !locations.isEmpty {
            let attributedText = NSMutableAttributedString()
            
            let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
            
            for (index, location) in locations.enumerated() {
                attributedText.append(NSMutableAttributedString(string: "\(location.nameLong)\n", attributes: attrs))
                attributedText.append(NSMutableAttributedString(string: location.nameShort))
                if index != (locations.count - 1) {
                    attributedText.append(NSMutableAttributedString(string: "\n\n"))
                }
            }
            cafeLocationsLabel.attributedText = attributedText
        } else {
            print("CafeDetailTableVC: Could not find and show location details.")
            cafeLocationsLabel.text = "Helaas kunnen wij momenteel geen locatie-details vinden."
        }
        
        //Find activities of selected Cafe
        if cafe != nil {
            activities = Activities.ofCafe(cafe!.nameShort)
        }
        
        //Count and return amount of activities in activityLabel
        var activityLabelText = ""
        
        switch activities.count {
        case 0:
            activityLabelText = "Er zijn geen activiteiten gevonden."
        case 1:
            activityLabelText = "Er is 1 activiteit gevonden."
        default:
            activityLabelText = "Er zijn \(activities.count) activiteiten gevonden."
        }
        
        activityLabel.text = activityLabelText
    }
    
    
    //Show DisclosureIndicator under activities if activities is not empty.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let cell: UITableViewCell! = tableView.cellForRow(at: IndexPath(row: 0, section: 1))
        
        if activities.isEmpty {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .disclosureIndicator
        }
    }
    
    //MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return (self.view!.bounds.height / 4)
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath == IndexPath(row: 0, section: 1) && !activities.isEmpty else { return }
        
        if let destination = storyboard?.instantiateViewController(withIdentifier: "ActivitiesTableViewController") as? ActivitiesTableViewController {
            destination.selectedCafe = cafe
            navigationController?.pushViewController(destination, animated: true)
        }
    }
    
    //Remove header of location-section
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat.leastNonzeroMagnitude : 32
    }
    
    //MARK: - Segues
    
}
