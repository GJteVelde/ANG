//
//  Cafe.swift
//  ANG
//
//  Created by Gerjan te Velde on 11/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation
import CloudKit
import MapKit

struct Cafe {
    typealias RecordId = GenericIdentifier<Cafe>
    
    static let keys =
        (
            title: "title",
            name: "name",
            region: "region",
            locations: "locations",
            favoriteCafesById: "FavoriteCafesById",
            recordType: "Cafe"
        )
    
    var record: CKRecord
    
    init(record: CKRecord) {
        self.record = record
    }
    
    init() {
        self.record = CKRecord(recordType: Cafe.keys.recordType)
    }
    
    var recordId: RecordId {
        return RecordId(recordId: record.recordID)
    }
    
    var name: String {
        get {
            return record.value(forKey: Cafe.keys.name) as! String
        }
        set {
            record.setValue(newValue, forKey: Cafe.keys.name)
        }
    }
    
    var region: Region.RecordId {
        get {
            let regionId = record.value(forKey: Cafe.keys.region) as! CKRecord.ID
            return Region.RecordId(recordId: regionId)
        }
        set {
            let reference = CKRecord.Reference(recordID: newValue.recordId, action: .deleteSelf)
            record.setValue(reference, forKey: Cafe.keys.region)
        }
    }
    
    var locations: [CLLocation] {
        get {
            return record.value(forKey: Cafe.keys.locations) as! [CLLocation]
        } set {
            record.setValue(newValue, forKey: Cafe.keys.locations)
        }
    }
    
    static var favoriteCafesById: [Cafe.RecordId: String] {
        get {
            return Cafe.loadLocallyStoredFavoriteCafesById()
        }
    }
}

extension Cafe: Comparable {
    static func < (lhs: Cafe, rhs: Cafe) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Cafe, rhs: Cafe) -> Bool {
        return lhs.recordId == rhs.recordId
    }
}

extension Cafe {
    var cafeAnnotations: [CafeAnnotation] {
        var cafeAnnotations = [CafeAnnotation]()
        
        for  location in locations {
            let newCafeAnnotation = CafeAnnotation(cafeId: self.recordId, name: self.name, location: location)
            cafeAnnotations.append(newCafeAnnotation)
        }
        
        return cafeAnnotations
    }
    
    class CafeAnnotation: NSObject, MKAnnotation {
        
        var cafeId: Cafe.RecordId
        var title: String?
        var coordinate: CLLocationCoordinate2D
        
        init(cafeId: Cafe.RecordId, name: String, location: CLLocation) {
            self.cafeId = cafeId
            self.title = name
            self.coordinate = location.coordinate
        }
    }
}

extension Cafe {
    /**
     Loads favorite cafés from UserDefaults.
     - Returns: A dictionary of cafes containing the CafeIds and names.
    */
    private static func loadLocallyStoredFavoriteCafesById() -> [Cafe.RecordId: String] {
        let userDefaults = UserDefaults.standard
        
        if let favoriteCafes = userDefaults.object(forKey: Cafe.keys.favoriteCafesById) as? [String: String] {
            var cafes = [Cafe.RecordId: String]()
            
            for cafe in favoriteCafes {
                let cafeId = CKRecord.ID(recordName: cafe.key)
                let cafeKey = Cafe.RecordId(recordId: cafeId)
                cafes[cafeKey] = cafe.value
            }
            return cafes
        }
        
        return [Cafe.RecordId: String]()
    }

    /**
     Saves favorite cafés in UserDefaults with the CafeIds and names.
     - Parameters:
        - cafes: A dictionary with CafeIds as keys and names as values.
    */
    private static func saveLocallyFavoriteCafesById(_ cafes: [Cafe.RecordId: String]) {
        var saveableCafes = [String: String]()
        
        for cafe in cafes {
            let cafeIdString = cafe.key.recordId.recordName
            saveableCafes[cafeIdString] = cafe.value
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(saveableCafes, forKey: Cafe.keys.favoriteCafesById)
    }
    
    static func saveLocallyFavoriteCafe(byId cafeId: Cafe.RecordId, cafeName: String) {
        var favoriteCafes = Cafe.loadLocallyStoredFavoriteCafesById()
        
        favoriteCafes[cafeId] = cafeName
        
        Cafe.saveLocallyFavoriteCafesById(favoriteCafesById)
    }
    
    static func deleteLocallyFavoriteCafe(byId cafeId: Cafe.RecordId) {
        var favoriteCafes = Cafe.loadLocallyStoredFavoriteCafesById()
        
        favoriteCafes.removeValue(forKey: cafeId)
        
        Cafe.saveLocallyFavoriteCafesById(favoriteCafes)
    }
    
    func saveLocallyAsFavoriteCafe() {
        var favoriteCafes = Cafe.loadLocallyStoredFavoriteCafesById()
        
        favoriteCafes[self.recordId] = self.name
        
        Cafe.saveLocallyFavoriteCafesById(favoriteCafes)
    }
    
    func deleteLocallyAsFavoriteCafe() {
        var favoriteCafes = Cafe.loadLocallyStoredFavoriteCafesById()
        
        favoriteCafes.removeValue(forKey: self.recordId)
        
        Cafe.saveLocallyFavoriteCafesById(favoriteCafes)
    }
    
    static func isFavorite(cafeId: Cafe.RecordId) -> Bool {
        let favoriteCafes = Cafe.loadLocallyStoredFavoriteCafesById()
        return favoriteCafes.keys.contains(cafeId)
    }
    
    /**
     Checks if the cafe is locally stored as a favorite cafe.
     - Returns: A tuple (*favorite*, *name?*) where name may return a String if the name saved locally is different from the name on the server. If the local name and the name on the server are equal, or if the cafe is not saved locally as favorite, it name returns nil.
     */
    func isLocallyFavoriteRegion() -> (isFavorite: Bool, localName: String?) {
        var favoriteCafes = Cafe.loadLocallyStoredFavoriteCafesById()
        
        if let savedName = favoriteCafes[self.recordId] {
            if savedName == self.name {
                return (true, nil)
            } else {
                return (true, savedName)
            }
        }
        
        return (false, nil)
    }
}
