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
    var annotations = [AnnotatedLocation]()
    
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
        annotations = AnnotatedLocation.returnAnnotations(of: cafes)
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
    //Show MkAnnotationViews on map, allow user to mark cafe as favorite, and create segue to CafeDetailViewController.
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
            
            let favoriteButton = UIButton(type: .custom)
            favoriteButton.frame.size = view.rightCalloutAccessoryView!.frame.size
            favoriteButton.layer.cornerRadius = view.rightCalloutAccessoryView!.frame.size.height / 2
            favoriteButton.tintColor = UIColor.white
            favoriteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
            favoriteButton.contentEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -6, right: -10)
            view.leftCalloutAccessoryView = favoriteButton
            
        }
        
        if let isFavorite = annotation.isFavorite, let favoriteButton = view.leftCalloutAccessoryView as? UIButton {
            if isFavorite {
                view.markerTintColor = UIColor.green
                favoriteButton.backgroundColor = UIColor.red
                favoriteButton.setTitle("-", for: .normal)
            } else {
                view.markerTintColor = UIColor.red
                favoriteButton.backgroundColor = UIColor.green
                favoriteButton.setTitle("+", for: .normal)
            }
        } else {
            view.markerTintColor = UIColor.red
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view.rightCalloutAccessoryView == control {
            performSegue(withIdentifier: "CafeDetailSegue", sender: view)
        } else {
            let location = view.annotation as! AnnotatedLocation
            
            if let index = annotations.index(of: location) {
                let selectedAnnotation = annotations[index]
                
                mapView.removeAnnotation(selectedAnnotation)
                selectedAnnotation.isFavorite = !selectedAnnotation.isFavorite!
                Cafes.all[selectedAnnotation.cafeShortName!]?.isFavorite = selectedAnnotation.isFavorite!
                mapView.addAnnotation(selectedAnnotation)
                
                //Check (and change) other locations of same cafe
                for i in annotations {
                    if i.cafeShortName == selectedAnnotation.cafeShortName {
                        mapView.removeAnnotation(i)
                        i.isFavorite = selectedAnnotation.isFavorite
                        mapView.addAnnotation(i)
                    }
                }
            }
        }
    }
    
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
            Cafe(nameShort: "Groningen", locations: ["Bernlef"], isFavorite: true),
            Cafe(nameShort: "Haren", locations: ["De Dilgt"], isFavorite: false),
            Cafe(nameShort: "Bedum", locations: ["Alegunda Ilberi"], isFavorite: false),
            Cafe(nameShort: "Hoogezand-Sappemeer", locations: ["De Burcht"], isFavorite: false),
            Cafe(nameShort: "Oldambt", locations: ["De Blanckenborg"], isFavorite: false),
            Cafe(nameShort: "Westerwolde-Kanaalstreek", locations: ["Maarsheerd"], isFavorite: false),
            Cafe(nameShort: "Veendam", locations: ["Breehorn", "Wildervanck"], isFavorite: true)
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
