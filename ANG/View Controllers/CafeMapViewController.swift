//
//  CafeMapViewController.swift
//  ANG
//
//  Created by Gerjan te Velde on 11/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import MapKit

class CafeMapViewController: UIViewController, MKMapViewDelegate {

    //MARK: - Properties
    @IBOutlet weak var cafesMap: MKMapView!
    var cloudKitService = CloudKitService.default
    
    var cafes = [Cafe]()
    var locationIds = [Location.RecordId]()
    var locations = [Location]()
    var locationAnnotations = [Location.Annotation]()
    
    var selectedCafeId: Cafe.RecordId?
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cafesMap.delegate = self
        loadAllCafes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cafesMap.removeAnnotations(locationAnnotations)
        cafesMap.addAnnotations(locationAnnotations)
    }

    //MARK: - Methods
    func loadAllCafes() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        cloudKitService.fetchAllCafesBasics { [unowned self] (result) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            switch result {
            case .failure(let resultError):
                let alert = UIAlertController(title: "Kon cafés niet laden", message: resultError.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Oké", style: .default))
                self.present(alert, animated: true)
            case .success(let resultCafes):
                self.cafes = resultCafes
                
                for cafe in resultCafes {
                    self.locationIds += cafe.locations
                }
                self.loadLocations()
            }
        }
    }
    
    func loadLocations() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        cloudKitService.fetchLocationsBasics(withLocationIds: locationIds) { [unowned self] (result) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            switch result {
            case .failure(let error):
                let alert = UIAlertController(title: "Kon locaties niet laden", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Oké", style: .default))
                self.present(alert, animated: true)
            case .success(let resultLocations):
                self.locations = resultLocations
                self.createAnnotations()
            }
        }
    }
    
    func createAnnotations() {
        for cafe in cafes {
            for locationId in cafe.locations {
                let cafeLocations = locations.filter { $0.recordId == locationId }
                
                for cafeLocation in cafeLocations {
                    let newAnnotation = Location.Annotation(withCafeName: cafe.name, cafeId: cafe.recordId, coordinate: cafeLocation.coordinate)
                    locationAnnotations.append(newAnnotation)
                }
            }
        }
        
        cafesMap.addAnnotations(locationAnnotations)
        cafesMap.centerAround(locationAnnotations, animated: true)
    }
    
    //MARK: - Segue
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CafeDetailSegue" {
            let destinationVC = segue.destination as! CafeDetailTableViewController
            guard let selectedCafe = (sender as? MKAnnotationView)?.annotation as? Location.Annotation else { return }
            destinationVC.cafeId = selectedCafe.cafeId
            destinationVC.title = selectedCafe.title!
        }
     }

    //MARK: - MapView Delegate Methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Location.Annotation else { return nil }
        
        let identifier = "cafe"
        var annotationView: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            annotationView = dequeuedView
        } else {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if Cafe.isFavorite(cafeId: annotation.cafeId!) {
            annotationView.markerTintColor = UIColor.angYellow
        } else {
            annotationView.markerTintColor = UIColor.angBlue
        }

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let selectedCafeId = view.annotation as? Location.Annotation {
            self.selectedCafeId = selectedCafeId.cafeId
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view.rightCalloutAccessoryView == control {
            performSegue(withIdentifier: "CafeDetailSegue", sender: view)
        }
    }
}
