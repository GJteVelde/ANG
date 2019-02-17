//
//  CafeMapViewController.swift
//  ANG
//
//  Created by Gerjan te Velde on 11/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import MapKit

class CafeMapViewController: UIViewController {

    //MARK: - Properties
    @IBOutlet weak var cafesMap: MKMapView!
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Test data
        fillMapWithExampleData()
        
        //Allow switching as user for authorization purposes
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Change User", style: .plain, target: self, action: #selector(editCurrentUser))
        
        //Center of mapForCafes
        //Create array from Cafes.all dictionary
        let cafes: [Cafe] = Cafes.all.map { $0.value }
        let annotations = AnnotatedLocation.returnAnnotations(of: cafes)
        let region = AnnotatedLocation.centerMapAround(annotations)
        cafesMap.setRegion(region, animated: true)
        
        //Show cafés on the map.
        cafesMap.delegate = self
        cafesMap.addAnnotations(annotations)
    }
    
    //Show alertController to ask if user wants to login as volunteer (allow editing-mode) or not (forbid editing-mode)
    @objc func editCurrentUser() {
        let alertController = UIAlertController(title: "Continue as volunteer?", message: "Continuing as volunteer allows you to edit content.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            CurrentUser.name = "Test-Admin"
            self.checkAuthorization()
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .default, handler: { (_) in
            CurrentUser.name = ""
            self.checkAuthorization()
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func checkAuthorization() {
        if CurrentUser.isAuthorized() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editingMode))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc func editingMode() {
        print("Enter editing mode.")
    }
}

extension CafeMapViewController: MKMapViewDelegate {
    //Show MkAnnotationViews on map and create segue to CafeDetailViewController.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? AnnotatedLocation else { return nil }
        
        let identifier = "cafe"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "CafeDetailSegue", sender: view)
    }
    
    //TODO: Segue to CafeDetailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CafeDetailSegue" {
            let destinationVC = segue.destination as! CafeDetailTableViewController
            let selectedCafe = (sender as! MKAnnotationView).annotation!.title!
            destinationVC.navigationItem.title = selectedCafe
            destinationVC.selectedCafe = selectedCafe?.replacingOccurrences(of: "Alzheimer Café ", with: "")
        }
    }
}

extension CafeMapViewController {
    func fillMapWithExampleData() {
        _ = [
            Cafe(nameShort: "Groningen", locations: ["Bernlef"]),
            Cafe(nameShort: "Haren", locations: ["De Dilgt"]),
            Cafe(nameShort: "Bedum", locations: ["Alegunda Ilberi"]),
            Cafe(nameShort: "Hoogezand-Sappemeer", locations: ["De Burcht"]),
            Cafe(nameShort: "Oldambt", locations: ["De Blanckenborg"]),
            Cafe(nameShort: "Westerwolde-Kanaalstreek", locations: ["Maarsheerd"]),
            Cafe(nameShort: "Veendam", locations: ["Breehorn", "Wildervanck"])
        ]
        
        _ = [
            Location(nameShort: "Bernlef", nameLong: "Woonzorgcentrum Bernlef", latitude: 53.2311925, longitude: 6.540431000000012),
            Location(nameShort: "De Dilgt", nameLong: "Woonzorgcentrum De Dilgt", latitude: 53.182748, longitude: 6.5955295999999635),
            Location(nameShort: "Alegunda Ilberi", nameLong: "Zorgcentrum Alegunda Ilberi", latitude: 53.2978878, longitude: 6.601139500000045),
            Location(nameShort: "De Burcht", nameLong: "Woonzorgcentrum De Burcht", latitude: 53.150691, longitude: 6.754647999999975),
            Location(nameShort: "De Blanckenborg", nameLong: "Zorgcentrum De Blanckenborg", latitude: 53.108733, longitude: 7.082443000000012),
            Location(nameShort: "Maarsheerd", nameLong: "Woon- en Zorgcentrum Maarsheerd", latitude: 52.99323039999999, longitude: 6.949502299999949),
            Location(nameShort: "Breehorn", nameLong: "Woonservicecentrum Breehorn", latitude: 53.0989283, longitude: 6.867970700000001),
            Location(nameShort: "Wildervanck", nameLong: "Woonzorgcentrum A.G. Wildervanck", latitude: 53.073946, longitude: 6.858611200000041)
        ]
        
        _ = [
            Activity(title: "Activity 1", location: "Bernlef", cafe: "Groningen"),
            Activity(title: "Activity 2", location: "Bernlef", cafe: "Groningen"),
            Activity(title: "Activity 3", location: "Bernlef", cafe: "Groningen"),
            Activity(title: "Activity 4", location: "Breehorn", cafe: "Veendam"),
            Activity(title: "Activity 5", location: "Wildervanck", cafe: "Veendam"),
            Activity(title: "Activity 6", location: "Breehorn", cafe: "Veendam"),
            Activity(title: "Activity 7", location: "Wildervanck", cafe: "Veendam"),
            Activity(title: "Activity 8", location: "Breehorn", cafe: "Veendam")
        ]
    }
}
