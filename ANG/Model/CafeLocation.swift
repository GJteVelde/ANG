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
}

extension CafeLocation {
    
    //Return all cafe-related locations as MKAnnotation to show on the map.
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
    
    //Automatically center map around input-locations with span of + 50%.
    static func centerMapAround(_ annotations: [MKAnnotation]) -> MKCoordinateRegion {
        var region = MKCoordinateRegion()
        
        //Check if there are annotations, otherwise center around HQ.
        guard annotations.count >= 1 else {
            region.center = CLLocationCoordinate2D(latitude: 52.1529872, longitude: 5.372167999999988)
            region.span = MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)
            return region
        }
        
        var coordinateMinimum: CLLocationCoordinate2D = annotations.first!.coordinate
        var coordinateMaximum: CLLocationCoordinate2D = annotations.first!.coordinate
        
        //Find and set lowest and highest latitude and longitude.
        for annotation in annotations {
            if coordinateMinimum.latitude > annotation.coordinate.latitude {
                coordinateMinimum.latitude = annotation.coordinate.latitude
            }
            if coordinateMaximum.latitude < annotation.coordinate.latitude {
                coordinateMaximum.latitude = annotation.coordinate.latitude
            }
            if coordinateMinimum.longitude > annotation.coordinate.longitude {
                coordinateMinimum.longitude = annotation.coordinate.longitude
            }
            if coordinateMaximum.longitude < annotation.coordinate.longitude {
                coordinateMaximum.longitude = annotation.coordinate.longitude
            }
        }
        
        //Calculate average latitude and longitude based on minimum and maximum values
        let averageLatitude = (coordinateMinimum.latitude + coordinateMaximum.latitude) / 2
        let averageLongitude = (coordinateMaximum.longitude + coordinateMinimum.longitude) / 2
        
        region.center = CLLocationCoordinate2D(latitude: averageLatitude, longitude: averageLongitude)
        
        //Calculate the span based on difference between minimum and maximum values and + 50%.
        let spanLatitude = (coordinateMaximum.latitude - coordinateMinimum.latitude) * 1.5
        let spanLongitude = (coordinateMaximum.longitude - coordinateMinimum.longitude) * 1.5
        
        region.span = MKCoordinateSpan(latitudeDelta: spanLatitude, longitudeDelta: spanLongitude)
        
        return region
    }
}
