//
//  MKMapViewExtensions.swift
//  ANG
//
//  Created by Gerjan te Velde on 14/05/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    
    /**
     Automatically center map around input-locations.
    */
    func centerAround(_ annotations: [MKAnnotation], animated: Bool) {
        var region = MKCoordinateRegion()
        
        //Check if there are annotations, otherwise center around HQ
        guard annotations.count >= 1 else {
            region.center = CLLocationCoordinate2D(latitude: 52.1529872, longitude: 5.372167999999988)
            region.span = MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)
            self.setRegion(region, animated: true)
            return
        }
        
        var coordinateMinimum: CLLocationCoordinate2D = annotations.first!.coordinate
        var coordinateMaximum: CLLocationCoordinate2D = annotations.first!.coordinate
        
        //Find and set lowest and highest latitude and longitude
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
        
        //Calculate center of map based on minimum and maximum values
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
        self.setRegion(region, animated: animated)
    }
}
