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
    var isFavorite: Bool
    
    var nameLong: String {
        return "Alzheimer Café \(nameShort)"
    }
    
    init(nameShort: String, locations: [String], isFavorite: Bool) {
        self.nameShort = nameShort
        self.locations = locations
        self.isFavorite = isFavorite
        
        Cafes.all[nameShort] = self
    }
}

struct Cafes {
    static var all = [String: Cafe]()
}
