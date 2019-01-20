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

    //MARK: - Objects
    @IBOutlet weak var cafesMap: MKMapView!
    
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Testdata to fill map
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

