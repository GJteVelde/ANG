//
//  MapViewController.swift
//  ANG
//
//  Created by Gerjan te Velde on 11/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    //MARK: - Objects
    @IBOutlet weak var mapForCafes: MKMapView!
    
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialization of mapForCafes
        var region = MKCoordinateRegion()
        region.center = CLLocationCoordinate2D(latitude: 53.2311925, longitude: 6.540431000000012)
        region.span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        mapForCafes.setRegion(region, animated: true)
        
        //Testdata to fill map
        _ = [
            Cafe(nameShort: "Groningen", locations: ["Bernlef"]),
            Cafe(nameShort: "Haren", locations: ["De Dilgt"])
        ]
        
        _ = [
            Location(nameShort: "Bernlef", nameLong: "Woonzorgcentrum Bernlef", latitude: 53.2311925, longitude: 6.540431000000012),
            Location(nameShort: "De Dilgt", nameLong: "Woonzorgcentrum De Dilgt", latitude: 53.182748, longitude: 6.5955295999999635),
        ]
        
        //Show cafés on the map.
        mapForCafes.delegate = self
        mapForCafes.addAnnotations(CafeLocation.returnAllAsAnnotations())
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? CafeLocation else { return nil }
        
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
}

