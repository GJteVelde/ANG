//
//  CafesLocations.swift
//  ANG
//
//  Created by Gerjan te Velde on 11/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation
import MapKit

class AnnotatedLocation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

extension AnnotatedLocation {
    //Return locations of cafe(s) as MKAnnotations to show on the map
    static func returnAnnotations(of cafes: [Cafe]) -> [MKAnnotation] {
        var annotations = [MKAnnotation]()
        
        for cafe in cafes {
            for cafeLocation in cafe.locations {
                if let location = Locations.all[cafeLocation] {
                    annotations.append(AnnotatedLocation(coordinate: location.coordinate, title: cafe.nameLong, subtitle: location.nameLong))
                } else {
                    print("CafeLocation: Could not find location \(cafeLocation) of \(cafe.nameLong)")
                }
            }
        }
        
        return annotations
    }
    
    //Return locations as MKAnnotations to show on the map of an individual cafe.
    static func returnAnnotations(of locations: [Location]) -> [MKAnnotation] {
        var annotations = [MKAnnotation]()
        
        for location in locations {
            annotations.append(AnnotatedLocation(coordinate: location.coordinate, title: location.nameLong, subtitle: nil))
        }
        
        return annotations
    }
    
    //Automatically center map around input-locations
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
        
        //If annotations.count == 1, return 0.1 span as there won't be a difference between minimum and maximum values.
        //Else, calculate the span based on difference between minimum and maximum values and + 50%
        var regionSpan = MKCoordinateSpan()
        
        if annotations.count == 1 {
            regionSpan.latitudeDelta = 0.01
            regionSpan.longitudeDelta = 0.01
        } else {
            regionSpan.latitudeDelta = (coordinateMaximum.latitude - coordinateMinimum.latitude) * 1.5
            regionSpan.longitudeDelta = (coordinateMaximum.longitude - coordinateMinimum.longitude) * 1.5
        }
        
        region.span = regionSpan
        
        return region
    }
}
