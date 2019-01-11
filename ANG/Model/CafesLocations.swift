//
//  CafesLocations.swift
//  ANG
//
//  Created by Gerjan te Velde on 11/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation
import MapKit

class CafeLocation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    static func returnAllAsAnnotations() -> [MKAnnotation] {
        var cafes = [MKAnnotation]()
        
        for cafe in Cafes.all {
            for cafeLocation in cafe.value.locations {
                if let location = Locations.all[cafeLocation] {
                    cafes.append(CafeLocation(coordinate: location.coordinate, title: cafe.value.nameLong, subtitle: location.nameLong))
                } else {
                    print("CafesLocations: Could not find location \(cafeLocation)")
                }
            }
        }
        return cafes
    }
}
