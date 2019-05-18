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
            name: "name",
            region: "region",
            locations: "locations",
            information: "information",
            headerImage: "headerImage",
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
            let regionReference = record.value(forKey: Cafe.keys.region) as! CKRecord.Reference
            return Region.RecordId(recordId: regionReference.recordID)
        }
        set {
            let reference = CKRecord.Reference(recordID: newValue.recordId, action: .deleteSelf)
            record.setValue(reference, forKey: Cafe.keys.region)
        }
    }
    
    var locations: [Location.RecordId] {
        get {
            let locationReferences = record.value(forKey: Cafe.keys.locations) as? [CKRecord.Reference] ?? [CKRecord.Reference]()
            
            var locationIds = [Location.RecordId]()
            for reference in locationReferences {
                locationIds.append(Location.RecordId(recordId: reference.recordID))
            }
            return locationIds
        }
        //TODO: Implement 'set' for locations.
    }
    
    
    var information: String {
        get {
            return record.value(forKey: Cafe.keys.information) as? String ?? "Er is geen informatie beschikbaar."
        }
        set {
            record.setValue(newValue, forKey: Cafe.keys.information)
        }
    }
    
    var headerImage: UIImage? {
        get {
            guard let headerImageUrl = (record.value(forKey: Cafe.keys.headerImage) as? CKAsset)?.fileURL else { return nil }
            guard let data = try? Data(contentsOf: headerImageUrl) else { return nil }
            return UIImage(data: data)
        }
        //TODO: Implement 'set' for headerImage.
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
    static func loadFavorites() -> [Cafe.RecordId: String] {
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

    private static func saveFavorites(cafeIdsAndNames cafes: [Cafe.RecordId: String]) {
        var saveableCafes = [String: String]()
        
        for cafe in cafes {
            let cafeIdString = cafe.key.recordId.recordName
            saveableCafes[cafeIdString] = cafe.value
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(saveableCafes, forKey: Cafe.keys.favoriteCafesById)
    }
    
    static func saveFavorite(cafeId: Cafe.RecordId, cafeName: String) {
        var favoriteCafes = Cafe.loadFavorites()
        
        favoriteCafes[cafeId] = cafeName
        
        Cafe.saveFavorites(cafeIdsAndNames: favoriteCafes)
    }
    
    static func deleteFavorite(cafeId: Cafe.RecordId) {
        var favoriteCafes = Cafe.loadFavorites()
        
        favoriteCafes.removeValue(forKey: cafeId)
        
        Cafe.saveFavorites(cafeIdsAndNames: favoriteCafes)
    }
    
    func saveAsFavorite() {
        Cafe.saveFavorite(cafeId: self.recordId, cafeName: self.name)
    }
    
    func deleteAsFavorite() {
        Cafe.deleteFavorite(cafeId: self.recordId)
    }
    
    func isFavorite() -> Bool {
        return Cafe.isFavorite(cafeId: self.recordId)
    }
    
    static func isFavorite(cafeId: Cafe.RecordId) -> Bool {
        let favoriteCafes = Cafe.loadFavorites()
        return favoriteCafes.keys.contains(cafeId)
    }
}

extension Cafe {
    static func returnFavoritesAsString() -> String {
        let favoriteCafes = Cafe.loadFavorites()
        let favoriteCafeNames = favoriteCafes.values.sorted()
        
        switch favoriteCafeNames.count {
        case 0:
            return "Er is nog geen favoriet café geselecteerd."
        case 1:
            return "Uw favoriete café is \(favoriteCafeNames.first!)."
        default:
            var tempFavoriteCafeNames = favoriteCafeNames
            let lastCafe = tempFavoriteCafeNames.removeLast()
            let favoriteCafeString = tempFavoriteCafeNames.joined(separator: ", ")
            return "Uw favoriete cafés zijn \(favoriteCafeString) en \(lastCafe)."
        }
    }
}
