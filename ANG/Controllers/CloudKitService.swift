//
//  CloudKitService.swift
//  ANG
//
//  Created by Gerjan te Velde on 10/05/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import Foundation
import CloudKit

class CloudKitService {
    static var `default` = CloudKitService()
    private let publicDatabase = CKContainer.default().publicCloudDatabase
}

//MARK: - Region Methods
extension CloudKitService {
    func fetchAllRegions(completionHandler: @escaping ((Result<[Region], Error>) -> Void)) {
        DispatchQueue.global().async {
            var regions = [Region]()
            
            let predicate = NSPredicate(value: true)
            let regionQuery = CKQuery(recordType: Region.keys.recordType, predicate: predicate)
            
            self.publicDatabase.perform(regionQuery, inZoneWith: nil) { (ckRecords, error) in
                if let ckError = error as? CKError {
                    DispatchQueue.main.async {
                        completionHandler(.failure(ckError))
                    }
                } else {
                    for ckRecord in ckRecords! {
                        let newRegion = Region(record: ckRecord)
                        regions.append(newRegion)
                    }
                    
                    DispatchQueue.main.async {
                        completionHandler(.success(regions))
                    }
                }
            }
        }
    }
    
    func fetchRegions(byIds regionIds: [Region.RecordId], completionHandler: @escaping ((Result<[Region], Error>) -> Void)) {
        let regionRecordIds = regionIds.map() { $0.recordId }
        var regions = [Region]()
        
        let fetchRegionsOperation = CKFetchRecordsOperation(recordIDs: regionRecordIds)
        
        fetchRegionsOperation.perRecordCompletionBlock = { (record, _, error) in
            guard error == nil else {
                return
            }
            let newRegion = Region(record: record!)
            regions.append(newRegion)
        }
        
        fetchRegionsOperation.fetchRecordsCompletionBlock = { (_, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    completionHandler(.failure(error!))
                    return
                }
                completionHandler(.success(regions))
            }
        }
        
        DispatchQueue.global().async {
            self.publicDatabase.add(fetchRegionsOperation)
        }
    }
}

//MARK: - Cafe Methods
extension CloudKitService {
    /**
     A method to be used when only basic details of all cafes are needed, e.g. for a map.
     - Parameters:
        - completionHandler: The block to execute with the search results.
     
     Uses the core API to fetch basic details only: name and locations. This information can be shown on a map.
    */
    func fetchAllCafesBasics(completionHandler: @escaping ((Result<[Cafe], Error>) -> Void)) {
        let predicate = NSPredicate(value: true)
        let cafeQuery = CKQuery(recordType: Cafe.keys.recordType, predicate: predicate)
        let sortDescriptors = NSSortDescriptor(key: Cafe.keys.name, ascending: true)
        cafeQuery.sortDescriptors = [sortDescriptors]
        
        let cafeQueryOperation = CKQueryOperation(query: cafeQuery)
        cafeQueryOperation.qualityOfService = .userInitiated
        cafeQueryOperation.desiredKeys = [Cafe.keys.name, Cafe.keys.locations]
        
        var fetchedCafes = [Cafe]()
        
        cafeQueryOperation.recordFetchedBlock = { record in
            let cafe = Cafe(record: record)
            fetchedCafes.append(cafe)
        }
        
        cafeQueryOperation.queryCompletionBlock = { (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
                    completionHandler(.success(fetchedCafes))
                } else {
                    guard let ckError = error as? CKError else {
                        completionHandler(.failure(error!))
                        return
                    }
                    completionHandler(.failure(ckError))
                }
            }
        }
        
        publicDatabase.add(cafeQueryOperation)
    }
    
    /**
     Method to fetch basic details (name and region) of specified cafés.
    */
    func fetchCafesBasics(cafeIds: [Cafe.RecordId], completionHandler: @escaping ((Result<[Cafe], Error>) -> Void)) {
        
        let cafeRecordIds = cafeIds.map() { $0.recordId }
        let cafeOperation = CKFetchRecordsOperation(recordIDs: cafeRecordIds)
        cafeOperation.desiredKeys = [Cafe.keys.name, Cafe.keys.region]
        
        var favoriteCafes = [Cafe]()
        
        cafeOperation.perRecordCompletionBlock = { (record, id, error) in
            guard error == nil else { return }
            let newCafe = Cafe(record: record!)
            favoriteCafes.append(newCafe)
        }
        
        cafeOperation.fetchRecordsCompletionBlock = { (_, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    completionHandler(.failure(error!))
                    return
                }
                favoriteCafes.sort()
                completionHandler(.success(favoriteCafes))
            }
        }
        
        DispatchQueue.global().async {
            self.publicDatabase.add(cafeOperation)
        }
    }
    
    /**
     Metod to fetch basic details only of cafes in the specified regions.
    */
    func fetchCafesBasicsInRegions(_ regionIds: [Region.RecordId], completionHandler: @escaping ((Result<[Cafe], Error>) -> Void)) {
        let regionReferences = regionIds.map() { CKRecord.Reference(recordID: $0.recordId, action: .none) }
        
        let predicate = NSPredicate(format: "\(Cafe.keys.region) IN %@", argumentArray: [regionReferences])
        let query = CKQuery(recordType: Cafe.keys.recordType, predicate: predicate)
        
        let sort = NSSortDescriptor(key: Cafe.keys.name, ascending: true)
        query.sortDescriptors = [sort]
        
        let fetchCafesOperation = CKQueryOperation(query: query)
        fetchCafesOperation.desiredKeys = [Cafe.keys.name, Cafe.keys.region]
        
        var cafes = [Cafe]()
        
        fetchCafesOperation.recordFetchedBlock = { (record) in
            let newCafe = Cafe(record: record)
            cafes.append(newCafe)
        }
        
        fetchCafesOperation.queryCompletionBlock = { (_, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    completionHandler(.failure(error!))
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(.success(cafes))
            }
        }
        
        DispatchQueue.global().async {
            self.publicDatabase.add(fetchCafesOperation)
        }
    }
    
    func fetchCafesBasicsAtLocations(_ locations: [Location], completionHandler: @escaping ((Result<[Cafe], Error>) -> Void)) {
        let locationReferences = locations.map() { CKRecord.Reference(recordID: $0.recordId.recordId, action: .none) }
        
        let predicate = NSPredicate(format: "ANY %@ in \(Cafe.keys.locations)", argumentArray: [locationReferences])
        //let predicate = NSPredicate(format: "\(Cafe.keys.locations) CONTAINS %@", argumentArray: [locationReferences])
        let query = CKQuery(recordType: Cafe.keys.recordType, predicate: predicate)
        
        let fetchCafesOperation = CKQueryOperation(query: query)
        
        var fetchedCafes = [Cafe]()
        
        fetchCafesOperation.recordFetchedBlock = { (record) in
            let newCafe = Cafe(record: record)
            fetchedCafes.append(newCafe)
        }
        
        fetchCafesOperation.queryCompletionBlock = { (_, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completionHandler(.failure(error))
                } else {
                    completionHandler(.success(fetchedCafes))
                }
            }
        }
        
        DispatchQueue.global().async {
            self.publicDatabase.add(fetchCafesOperation)
        }
    }
    
    /**
     A method to fetch details of a selected cafe, excluding eventual assets and region.
    */
    func fetchCafe(_ cafeId: Cafe.RecordId, completionHandler: @escaping ((Result<Cafe, Error>) -> Void)) {
        
        let fetchCafeOperation = CKFetchRecordsOperation(recordIDs: [cafeId.recordId])
        fetchCafeOperation.desiredKeys = [
            Cafe.keys.name,
            Cafe.keys.information,
            Cafe.keys.locations
        ]
        fetchCafeOperation.qualityOfService = .userInitiated
        
        var cafe: Cafe!
        
        fetchCafeOperation.perRecordCompletionBlock = { (record, recordId, error) in
            guard error == nil else { return }
            cafe = Cafe(record: record!)
        }
        
        fetchCafeOperation.fetchRecordsCompletionBlock = { (_, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completionHandler(.failure(error))
                } else {
                    completionHandler(.success(cafe))
                }
            }
        }
        
        DispatchQueue.global().async {
            self.publicDatabase.add(fetchCafeOperation)
        }
    }
    
    func fetchCafeAssets(cafeId: Cafe.RecordId, completionHandler: @escaping ((Result<UIImage?, Error>) -> Void)) {
        let fetchOperation = CKFetchRecordsOperation(recordIDs: [cafeId.recordId])
        fetchOperation.desiredKeys = [Cafe.keys.headerImage]
        fetchOperation.qualityOfService = .userInitiated
        
        var image: UIImage?
        
        fetchOperation.perRecordCompletionBlock = { (record, recordId, error) in
            guard error == nil else { return }
            let cafe = Cafe(record: record!)
            image = cafe.headerImage
        }
        
        fetchOperation.fetchRecordsCompletionBlock = { (result, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completionHandler(.failure(error))
                } else {
                    completionHandler(.success(image))
                }
            }
        }
        
        DispatchQueue.global().async {
            self.publicDatabase.add(fetchOperation)
        }
    }
}

//MARK: - Location Methods
extension CloudKitService {
    /**
     A method to fetch full details of locations.
    */
    func fetchLocationsDetails(withLocationIds locationIds: [Location.RecordId], completionHandler: @escaping ((Result<[Location], Error>) -> Void)) {
        
        var locationRecordIds = [CKRecord.ID]()
        for id in locationIds {
            locationRecordIds.append(id.recordId)
        }
        
        var locations = [Location]()
        
        let fetchLocationsOperation = CKFetchRecordsOperation(recordIDs: locationRecordIds)
        fetchLocationsOperation.qualityOfService = .userInitiated
        
        fetchLocationsOperation.perRecordCompletionBlock = { (record, recordId, error) in
            guard error == nil else { return }
            let newLocation = Location(record: record!)
            locations.append(newLocation)
        }
        
        fetchLocationsOperation.fetchRecordsCompletionBlock = { (_, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completionHandler(.failure(error))
                } else {
                    completionHandler(.success(locations))
                }
            }
        }
        
        DispatchQueue.global().async {
            self.publicDatabase.add(fetchLocationsOperation)
        }
    }
    
    /**
     This methods fetches the coordinates only of locations to be shown on a map.
    */
    func fetchLocationsBasics(withLocationIds locationIds: [Location.RecordId], completionHandler: @escaping ((Result<[Location], Error>) -> Void)) {
        
        var locationRecordIds = [CKRecord.ID]()
        for id in locationIds {
            locationRecordIds.append(id.recordId)
        }
        
        var locations = [Location]()
        
        let fetchLocationsOperation = CKFetchRecordsOperation(recordIDs: locationRecordIds)
        fetchLocationsOperation.desiredKeys = [Location.keys.clLocation, Location.keys.type, Location.keys.name, Location.keys.streetAndNumber, Location.keys.postalCode, Location.keys.city]
        fetchLocationsOperation.qualityOfService = .userInitiated
        
        fetchLocationsOperation.perRecordCompletionBlock = { (record, recordId, error) in
            guard error == nil else { return }
            let newLocation = Location(record: record!)
            locations.append(newLocation)
        }
        
        fetchLocationsOperation.fetchRecordsCompletionBlock = { (_, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completionHandler(.failure(error))
                } else {
                    completionHandler(.success(locations))
                }
            }
        }
        
        DispatchQueue.global().async {
            self.publicDatabase.add(fetchLocationsOperation)
        }
    }
    
    func fetchLocationsBasicsWithRadius(inKm radiusInKm: CLLocationDistance, around location: CLLocation, completionHandler: @escaping ((Result<[Location], Error>) -> Void)) {
        let predicate = NSPredicate(format: "distanceToLocation:fromLocation:(\(Location.keys.clLocation), %@) < %f", location, (radiusInKm * 1000))
        let locationQuery = CKQuery(recordType: Location.keys.recordType, predicate: predicate)
        
        let sortDescriptor = CKLocationSortDescriptor(key: Location.keys.clLocation, relativeLocation: location)
        locationQuery.sortDescriptors = [sortDescriptor]
        
        let locationQueryOperation = CKQueryOperation(query: locationQuery)
        
        var fetchedLocations = [Location]()
        
        locationQueryOperation.recordFetchedBlock = { (record) in
            let newLocation = Location(record: record)
            fetchedLocations.append(newLocation)
        }
        
        locationQueryOperation.queryCompletionBlock = { (_, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completionHandler(.failure(error))
                } else {
                    completionHandler(.success(fetchedLocations))
                }
            }
        }
        
        DispatchQueue.global().async {
            self.publicDatabase.add(locationQueryOperation)
        }
    }
}
