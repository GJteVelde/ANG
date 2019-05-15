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
    
    var isFavorite = false {
        didSet {
            if isFavorite {
                saveFavoriteButton.setTitle("Verwijder als favoriet", for: .normal)
            } else {
                saveFavoriteButton.setTitle("Voeg toe als favoriet", for: .normal)
            }
        }
    }
    
    var cloudKitService = CloudKitService.default
    
    var activities: [Activity] = []
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var cafeLocationsMap: MKMapView!
    @IBOutlet weak var cafeLocationsLabel: UILabel!
    @IBOutlet var activityLabel: UILabel!
    @IBOutlet weak var saveFavoriteButton: UIButton!
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerImageView.alpha = 0
        
        cafeLocationsMap.delegate = self
        cafeLocationsMap.isZoomEnabled = false
        cafeLocationsMap.isPitchEnabled = false
        cafeLocationsMap.isRotateEnabled = false
        cafeLocationsMap.isScrollEnabled = false
        cafeLocationsMap.isUserInteractionEnabled = false
        
        loadCafe()
        
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
        if indexPath.section == TableSection.headerImage.rawValue && indexPath.row == 0 {
            if cafe?.headerImage != nil {
                return view.bounds.height / 4
            } else {
                return CGFloat.leastNonzeroMagnitude
            }
        } else if indexPath.section == TableSection.location.rawValue && indexPath.row == 0 {
            return view.bounds.height / 4
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == TableSection.headerImage.rawValue || section == TableSection.information.rawValue {
            return CGFloat.leastNonzeroMagnitude
        }
        return UITableView.automaticDimension
    }
    
    //MARK: - MapView Delegate Methods
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
        
        if isFavorite {
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
                self.isFavorite = Cafe.isFavorite(cafeId: cafe.recordId)
                
                if let headerImage = cafe.headerImage {
                    self.headerImageView.image = headerImage
                    self.headerImageView.alpha = 1
                }
                
                self.informationLabel.text = cafe.information
                for cafeAnnotation in cafe.cafeAnnotations {
                    self.cafeAnnotations.append(cafeAnnotation)
                }
                
                self.cafeLocationsLabel.attributedText = cafe.returnAddressAsAttributedString()
                
                self.cafeLocationsMap.addAnnotations(self.cafeAnnotations)
                self.cafeLocationsMap.centerAround(self.cafeAnnotations)
                
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }
    
    //MARK: - Actions
    @IBAction func saveFavoriteButtonTouchUpInside(_ sender: UIButton) {
        isFavorite = !isFavorite
        
        if isFavorite {
            cafe!.saveLocallyAsFavoriteCafe()
        } else {
            cafe!.deleteLocallyAsFavoriteCafe()
        }
        
        cafeLocationsMap.removeAnnotations(cafeAnnotations)
        cafeLocationsMap.addAnnotations(cafeAnnotations)
    }
}

extension CafeDetailTableViewController {
    
    enum TableSection: Int {
        case headerImage = 0
        case information
        case location
        case activities
        case actions
    }
}
