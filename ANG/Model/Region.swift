//
//  Region.swift
//  ANG
//
//  Created by Gerjan te Velde on 10/05/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation
import CloudKit

struct Region: Comparable, Equatable {
    
    static let recordType = "Region"
    
    let regionID: CKRecord.ID
    let name: String
    let province: String
    
    static func < (lhs: Region, rhs: Region) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Region, rhs: Region) -> Bool {
        return lhs.regionID.recordName == rhs.regionID.recordName
    }
}

extension Region {
    static func loadLocallyStoredFavoriteRegionsByIdName() -> [String: String] {
        let userDefaults = UserDefaults.standard
        
        if let favoriteRegions = userDefaults.object(forKey: "FavoriteRegionsByIdName") as? [String: String] {
            return favoriteRegions
        }
        return [String: String]()
    }
    
    static func saveLocallyFavoriteRegionsByIdName(_ regions: [String: String]) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(regions, forKey: "FavoriteRegionsByIdName")
    }
}
