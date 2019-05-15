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
     - Returns: A dictionary where the key is the regionID name (*CKRecord.ID.recordName*) and its value is the name of the region.
    */
    static func loadLocallyStoredFavoriteRegionsById() -> [Region.RecordId: String] {
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
    private static func saveLocallyFavoriteRegionsById(_ regions: [Region.RecordId: String]) {
        var saveableRegions = [String: String]()
        
        for region in regions {
            let regionIdStringKey = region.key.recordId.recordName
            saveableRegions[regionIdStringKey] = region.value
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(saveableRegions, forKey: Region.keys.favoriteRegionsById)
    }
    
    static func returnLocallyFavoriteRegionsAsString() -> String {
        let favoriteRegions = Region.loadLocallyStoredFavoriteRegionsById()
        let favoriteRegionsByName = favoriteRegions.values.sorted()
        
        if favoriteRegionsByName.count == 0 {
            return "Er is nog geen favoriete afdeling geselecteerd."
        } else if favoriteRegionsByName.count == 1 {
            return "Uw favoriete afdeling is \(favoriteRegionsByName.first!)."
        } else {
            var tempFavoriteRegionsByName = favoriteRegionsByName
            let lastRegion = tempFavoriteRegionsByName.removeLast()
            let favoriteRegionsString = tempFavoriteRegionsByName.joined(separator: ", ")
            return "Uw favoriete afdelingen zijn \(favoriteRegionsString) en \(lastRegion)."
        }
    }
    
    func saveLocallyAsFavoriteRegion() {
        var favoriteRegions = Region.loadLocallyStoredFavoriteRegionsById()
        
        favoriteRegions[self.recordId] = self.name
        
        Region.saveLocallyFavoriteRegionsById(favoriteRegions)
    }
    
    func deleteLocallyAsFavoriteRegion() {
        var favoriteRegions = Region.loadLocallyStoredFavoriteRegionsById()
        
        favoriteRegions.removeValue(forKey: self.recordId)
        
        Region.saveLocallyFavoriteRegionsById(favoriteRegions)
    }
    
    /**
     Checks if the region is locally stored as a favorite region.
     - Returns: A tuple (*favorite*, *name?*) where name may return a String if the name saved locally is different from the name on the server. If the local name and the name on the server are equal, or if the region is not saved locally as favorite, it name returns nil.
    */
    func isLocallyFavoriteRegion() -> (isFavorite: Bool, localName: String?) {
        var favoriteRegions = Region.loadLocallyStoredFavoriteRegionsById()
        
        if let savedName = favoriteRegions[self.recordId] {
            if savedName == self.name {
                return (true, nil)
            } else {
                return (true, savedName)
            }
        }
        
        return (false, nil)
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
