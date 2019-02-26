//
//  Location.swift
//  ANG
//
//  Created by Gerjan te Velde on 11/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation
import MapKit

struct Location {
    var nameShort: String
    var nameLong: String
    var latitude: Double
    var longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(nameShort: String, nameLong: String, latitude: Double, longitude: Double) {
        self.nameShort = nameShort
        self.nameLong = nameLong
        self.latitude = latitude
        self.longitude = longitude
        
        Locations.all[nameShort] = self
    }
}

struct Locations {
    static var all = [String: Location]()
}
