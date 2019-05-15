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
            addresses: "addresses",
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
        }
        set {
            record.setValue(newValue, forKey: Cafe.keys.locations)
        }
    }
    
    var addresses: [String] {
        get {
            return record.value(forKey: Cafe.keys.addresses) as? [String] ?? [String]()
        }
        set {
            record.setValue(newValue, forKey: Cafe.keys.addresses)
        }
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
        //TODO: implement 'set' for headerImage.
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
    func returnAddressAsAttributedString() -> NSAttributedString {
        guard !addresses.isEmpty else {
            return NSAttributedString(string: "Er zijn geen adresgegevens beschikbaar.")
        }
        
        let addressAttributedString = NSMutableAttributedString(string: "")
        
        for (index, address) in addresses.enumerated() {
            let addressAsNSString = address as NSString
            let lineBreakRange = addressAsNSString.range(of: "\n")
            let boldRange: NSRange = NSRange(location: 0, length: lineBreakRange.location)
            
            let attributedAddress = NSMutableAttributedString(string: address)
            let attribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
            attributedAddress.addAttributes(attribute, range: boldRange)
            addressAttributedString.append(attributedAddress)
            
            if index != (addresses.endIndex - 1) {
               addressAttributedString.append(NSAttributedString(string: "\n\n"))
            }
        }
        
        return NSAttributedString(attributedString: addressAttributedString)
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
        
        Cafe.saveLocallyFavoriteCafesById(favoriteCafes)
    }
    
    static func deleteLocallyFavoriteCafe(byId cafeId: Cafe.RecordId) {
        var favoriteCafes = Cafe.loadLocallyStoredFavoriteCafesById()
        
        favoriteCafes.removeValue(forKey: cafeId)
        
        Cafe.saveLocallyFavoriteCafesById(favoriteCafes)
    }
    
    func saveLocallyAsFavoriteCafe() {
        Cafe.saveLocallyFavoriteCafe(byId: self.recordId, cafeName: self.name)
    }
    
    func deleteLocallyAsFavoriteCafe() {
        Cafe.deleteLocallyFavoriteCafe(byId: self.recordId)
    }
    
    static func isFavorite(cafeId: Cafe.RecordId) -> Bool {
        let favoriteCafes = Cafe.loadLocallyStoredFavoriteCafesById()
        return favoriteCafes.keys.contains(cafeId)
    }
}
