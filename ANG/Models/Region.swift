//
//  Region.swift
//  ANG
//
//  Created by Gerjan te Velde on 10/05/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation
import CloudKit

struct Region {
    typealias RecordId = GenericIdentifier<Region>
    
    static let keys =
        (
            name: "name",
            province: "province",
            favoriteRegionsById: "FavoriteRegionsById",
            recordType: "Region"
        )
    
    var record: CKRecord
    
    init(record: CKRecord) {
        self.record = record
    }
    
    init() {
        self.record = CKRecord(recordType: Region.keys.recordType)
    }
    
    var recordId: RecordId {
        get {
            return RecordId(recordId: record.recordID)
        }
    }
    
    var name: String {
        get {
            return self.record.value(forKey: Region.keys.name) as! String
        }
        set {
            self.record.setValue(newValue, forKey: Region.keys.name)
        }
    }
    
    var province: Province {
        get {
            let provinceString = self.record.value(forKey: Region.keys.province) as! String
            return Province(rawValue: provinceString)!
        }
        set {
            self.record.setValue(newValue.rawValue, forKey: Region.keys.province)
        }
    }
    
    var nameLong: String {
        return "Afdeling \(name)"
    }
}

extension Region: Comparable, Equatable {
    static func < (lhs: Region, rhs: Region) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Region, rhs: Region) -> Bool {
        return lhs.recordId == rhs.recordId
    }
}

extension Region {
    /**
     Loads favorite regions from UserDefaults and returns them as a dictionary.
     - Returns: A dictionary where the key is the regionID name (*CKRecord.ID.recordName*) and its value is the stored name of the region.
    */
    static func loadFavorites() -> [Region.RecordId: String] {
        let userDefaults = UserDefaults.standard
        
        if let favoriteRegions = userDefaults.object(forKey: Region.keys.favoriteRegionsById) as? [String: String] {
            var regions = [Region.RecordId: String]()
            
            for region in favoriteRegions {
                let regionId = CKRecord.ID(recordName: region.key)
                let regionKey = Region.RecordId(recordId: regionId)
                
                regions[regionKey] = region.value
            }
            return regions
        }
        return [Region.RecordId: String]()
    }
    
    /**
     Saves favorite regions in UserDefaults as a dictionary: key is regionID name, value the region name.
     - Parameters:
        - regions: Takes a dictionary of type *[String: String]*. The key should be the regionID name (*CKRecord.ID.recordName*) and the value the name of the region.
    */
    private static func saveFavorites(regionIdsAndNames regions: [Region.RecordId: String]) {
        var saveableRegions = [String: String]()
        
        for region in regions {
            let regionIdStringKey = region.key.recordId.recordName
            saveableRegions[regionIdStringKey] = region.value
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(saveableRegions, forKey: Region.keys.favoriteRegionsById)
    }
    
    func saveAsFavorite() {
        var favoriteRegions = Region.loadFavorites()
        
        favoriteRegions[self.recordId] = self.name
        
        Region.saveFavorites(regionIdsAndNames: favoriteRegions)
    }
    
    func deleteAsFavorite() {
        var favoriteRegions = Region.loadFavorites()
        
        favoriteRegions.removeValue(forKey: self.recordId)
        
        Region.saveFavorites(regionIdsAndNames: favoriteRegions)
    }
    
    /**
     Checks if the region is locally stored as a favorite region.
    */
    func isFavorite() -> Bool {
        let favoriteRegions = Region.loadFavorites()
        return favoriteRegions.keys.contains(self.recordId)
    }
}

extension Region {
    static func returnFavoritesAsString() -> String {
        let favoriteRegions = Region.loadFavorites()
        let favoriteRegionNames = favoriteRegions.values.sorted()
        
        switch favoriteRegionNames.count {
        case 0:
            return "Er is nog geen favoriete afdeling geselecteerd."
        case 1:
            return "Mijn favoriete afdeling is \(favoriteRegionNames.first!)."
        default:
            var tempFavoriteRegionNames = favoriteRegionNames
            let lastRegion = tempFavoriteRegionNames.removeLast()
            let favoriteRegionString = tempFavoriteRegionNames.joined(separator: ", ")
            return "Mijn favoriete afdelingen zijn \(favoriteRegionString) en \(lastRegion)."
        }
    }
}

extension Region {
    enum Province: String, CaseIterable, Comparable {
        case drenthe = "Drenthe"
        case flevoland = "Flevoland"
        case friesland = "Friesland"
        case gelderland = "Gelderland"
        case groningen = "Groningen"
        case limburg = "Limburg"
        case noordBrabant = "Noord-Brabant"
        case noordHolland = "Noord-Holland"
        case overijssel = "Overijssel"
        case utrecht = "Utrecht"
        case zeeland = "Zeeland"
        case zuidHolland = "Zuid-Holland"
        
        static func < (lhs: Region.Province, rhs: Region.Province) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
}
