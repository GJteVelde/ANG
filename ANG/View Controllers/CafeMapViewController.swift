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
    var cafeAnnotations = [Cafe.CafeAnnotation]()
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cafesMap.delegate = self
        loadAllCafes()
    }

    //MARK: - Methods
    func loadAllCafes() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        cloudKitService.fetchAllCafesBasicDetails { [unowned self] (result) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            switch result {
            case .failure(let resultError):
                let alert = UIAlertController(title: "Kon cafés niet laden", message: resultError.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Oké", style: .default))
                self.present(alert, animated: true)
            case .success(let resultCafes):
                self.cafes = resultCafes
                
                for cafe in resultCafes {
                    for cafeAnnotation in cafe.cafeAnnotations {
                        self.cafeAnnotations.append(cafeAnnotation)
                    }
                }
                
                self.cafesMap.addAnnotations(self.cafeAnnotations)
                self.cafesMap.centerAround(self.cafeAnnotations)
            }
        }
    }
    
    //MARK: - Segue
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CafeDetailSegue" {
            let destinationVC = segue.destination as! CafeDetailTableViewController
            guard let selectedCafe = (sender as? MKAnnotationView)?.annotation as? Cafe.CafeAnnotation else { return }
            destinationVC.cafeId = selectedCafe.cafeId
            destinationVC.title = selectedCafe.title!
        }
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
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if Cafe.isFavorite(cafeId: annotation.cafeId) {
            annotationView.markerTintColor = UIColor.angYellow
        } else {
            annotationView.markerTintColor = UIColor.angBlue
        }

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view.rightCalloutAccessoryView == control {
            performSegue(withIdentifier: "CafeDetailSegue", sender: view)
        }
    }
}
