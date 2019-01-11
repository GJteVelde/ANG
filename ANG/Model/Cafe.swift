//
//  Cafe.swift
//  ANG
//
//  Created by Gerjan te Velde on 11/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation

struct Cafe {
    var nameShort: String
    var locations: [String]
    
    var nameLong: String {
        return "Alzheimer Café \(nameShort)"
    }
    
    init(nameShort: String, locations: [String]) {
        self.nameShort = nameShort
        self.locations = locations
        Cafes.all[nameShort] = self
    }
}

struct Cafes {
    static var all = [String: Cafe]()
}
