//
//  CafeDetailTableViewController.swift
//  ANG
//
//  Created by Gerjan te Velde on 12/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import MapKit

class CafeDetailTableViewController: UITableViewController, MKMapViewDelegate {
    
    //MARK: Properties
    var cafeId: Cafe.RecordId!
    var cafe: Cafe?
    var cafeAnnotations = [Cafe.CafeAnnotation]()
    
    var cloudKitService = CloudKitService.default
    
    var locations: [Location] = []
    var activities: [Activity] = []
    
    @IBOutlet weak var cafeLocationsMap: MKMapView!
    @IBOutlet weak var cafeLocationsLabel: UILabel!
    @IBOutlet var activityLabel: UILabel!
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cafeLocationsMap.delegate = self
        loadCafe()
        
        //Show location-details of Cafe in cafeLocationsLabel
        /*
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
        */
        
        /*
        //Find activities of selected Cafe
        if cafe != nil {
            activities = Activities.ofCafe(cafe!.nameShort)
        }
        */
        
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
    
    //Show DisclosureIndicator under activities and allow cell selection if activities is not empty.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let cell: UITableViewCell! = tableView.cellForRow(at: IndexPath(row: 0, section: 1))
        
        if activities.isEmpty {
            cell.accessoryType = .none
            cell.isUserInteractionEnabled = false
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
        
        if let destination = storyboard?.instantiateViewController(withIdentifier: "ActivitiesIdentifier") as? ActivitiesTableViewController {
            destination.selectedCafe = cafe
            navigationController?.pushViewController(destination, animated: true)
        }
    }
    
    //Remove header of location-section
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat.leastNonzeroMagnitude : 32
    }

    //MARK - MapView Delegate Methods
    //Change appearence of annotations according to Cafe.isFavorite
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Cafe.CafeAnnotation else { return nil }
        
        let identifier = "cafe"
        var annotationView: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            annotationView = dequeuedView
        } else {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = false
        }
        
        if Cafe.isFavorite(cafeId: cafeId) {
            annotationView.markerTintColor = UIColor.angYellow
        } else {
            annotationView.markerTintColor = UIColor.angBlue
        }
        
        return annotationView
    }

    //MARK: - Methods
    func loadCafe() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        cloudKitService.fetchCafe(cafeId: cafeId) { [unowned self] (result) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            switch result {
            case .failure(let error):
                let alert = UIAlertController(title: "Kon cafe niet laden", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Oké", style: .default))
                self.present(alert, animated: true)
            case .success(let cafe):
                self.cafe = cafe
                
                for cafeAnnotation in cafe.cafeAnnotations {
                    self.cafeAnnotations.append(cafeAnnotation)
                }
                
                self.cafeLocationsMap.addAnnotations(self.cafeAnnotations)
                self.cafeLocationsMap.centerAround(self.cafeAnnotations)
            }
        }
    }
}
