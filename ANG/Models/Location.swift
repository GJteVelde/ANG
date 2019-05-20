//
//  Location.swift
//  ANG
//
//  Created by Gerjan te Velde on 16/05/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation
import CloudKit
import MapKit

struct Location {
    typealias RecordId = GenericIdentifier<Location>
    
    static let keys =
        (
            type: "type",
            name: "name",
            streetAndNumber: "streetAndNumber",
            postalCode: "postalCode",
            city: "city",
            clLocation: "coordinate",
            recordType: "Location"
        )
    
    var record: CKRecord
    
    init(record: CKRecord) {
        self.record = record
    }
    
    init() {
        self.record = CKRecord(recordType: Location.keys.recordType)
    }
    
    var recordId: RecordId {
        return RecordId(recordId: record.recordID)
    }
    
    var type: String {
        get {
            return record.value(forKey: Location.keys.type) as? String ?? ""
        }
        set {
            record.setValue(newValue, forKey: Location.keys.type)
        }
    }
    
    var name: String {
        get {
            return record.value(forKey: Location.keys.name) as? String ?? ""
        }
        set {
            record.setValue(newValue, forKey: Location.keys.type)
        }
    }
    
    var streetAndNumber: String {
        get {
            return record.value(forKey: Location.keys.streetAndNumber) as? String ?? ""
        }
        set {
            record.setValue(newValue, forKey: Location.keys.streetAndNumber)
        }
    }
    
    var postalCode: String {
        get {
            return record.value(forKey: Location.keys.postalCode) as? String ?? ""
        }
        set {
            record.setValue(newValue, forKey: Location.keys.postalCode)
        }
    }
    
    var city: String {
        get {
            return record.value(forKey: Location.keys.city) as? String ?? ""
        }
        set {
            record.setValue(newValue, forKey: Location.keys.city)
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            let fetchedCoordinate = record.value(forKey: Location.keys.clLocation) as! CLLocation
            let coordinate = CLLocationCoordinate2D(latitude: fetchedCoordinate.coordinate.latitude, longitude: fetchedCoordinate.coordinate.longitude)
            return coordinate
        }
    }
    
    var clLocation: CLLocation {
        get {
            return record.value(forKey: Location.keys.clLocation) as! CLLocation
        }
        set {
            record.setValue(newValue, forKey: Location.keys.clLocation)
        }
    }
}

extension Location {
    func returnAddressAsAtributedString() -> NSAttributedString {
        let addressAtributedString = NSMutableAttributedString(string: "")
        let boldAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
        
        switch (type != "", name != "") {
        case (true, true):
            addressAtributedString.append(NSAttributedString(string: "\(type) \(name)\n", attributes: boldAttribute))
        case (false, true):
            addressAtributedString.append(NSAttributedString(string: "\(name)\n", attributes: boldAttribute))
        case (true, false):
            addressAtributedString.append(NSAttributedString(string: "\(type)\n", attributes: boldAttribute))
        default:
            break
        }
        
        if streetAndNumber != "" {
            addressAtributedString.append(NSAttributedString(string: "\(streetAndNumber)\n"))
        }
        
        switch (postalCode != "", city != "") {
        case (true, true):
            addressAtributedString.append(NSAttributedString(string: "\(postalCode) \(city)\n"))
        case (true, false):
            addressAtributedString.append(NSAttributedString(string: "\(postalCode)\n"))
        case (false, true):
            addressAtributedString.append(NSAttributedString(string: "\(city)\n"))
        default:
            break
        }
        
        return addressAtributedString
    }
    
    static func returnAddressesAsAtributedString(ofLocations locations: [Location]) -> NSAttributedString {
        let attributedAddress = NSMutableAttributedString(string: "")
        
        for (index, location) in locations.enumerated() {
            let address = location.returnAddressAsAtributedString()
            attributedAddress.append(address)
            
            if index != (locations.endIndex - 1) && address != NSAttributedString(string: "") {
                attributedAddress.append(NSAttributedString(string: "\n"))
            }
        }
        
        attributedAddress.deleteCharacters(in: NSRange(location: (attributedAddress.length) - 1, length: 1))
        
        return attributedAddress
    }
}

extension Location {
    class Annotation: NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D
        
        var title: String?
        var subtitle: String?
        
        var cafeId: Cafe.RecordId?
        
        init(withLocationName locationName: String, cafeId: Cafe.RecordId, coordinate: CLLocationCoordinate2D) {
            self.title = locationName
            self.coordinate = coordinate
            self.cafeId = cafeId
        }
        
        init(withCafeName cafeName: String, cafeId: Cafe.RecordId, coordinate: CLLocationCoordinate2D) {
            self.title = cafeName
            self.cafeId = cafeId
            self.coordinate = coordinate
        }
    }
}
