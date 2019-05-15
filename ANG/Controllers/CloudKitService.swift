//
//  CloudKitService.swift
//  ANG
//
//  Created by Gerjan te Velde on 10/05/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

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
}

//MARK: - Cafe Methods
extension CloudKitService {
    /**
     A method to be used when only basic details of all cafes are needed.
     - Parameters:
        - completionHandler: The block to execute with the search results.
     
     Uses the core API to fetch basic details only: name, region, and locations. This information can be shown on a map.
    */
    func fetchAllCafesBasicDetails(completionHandler: @escaping ((Result<[Cafe], Error>) -> Void)) {
        let predicate = NSPredicate(value: true)
        let cafeQuery = CKQuery(recordType: Cafe.keys.recordType, predicate: predicate)
        let sortDescriptors = NSSortDescriptor(key: Cafe.keys.name, ascending: true)
        cafeQuery.sortDescriptors = [sortDescriptors]
        
        let cafeQueryOperation = CKQueryOperation(query: cafeQuery)
        cafeQueryOperation.desiredKeys = [Cafe.keys.name, Cafe.keys.region, Cafe.keys.locations]
        
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
     A method to fetch all details of a selected cafe, including eventual assets.
    */
    func fetchCafe(cafeId: Cafe.RecordId, completionHandler: @escaping ((Result<Cafe, Error>) -> Void)) {
        publicDatabase.fetch(withRecordID: cafeId.recordId) { (record, error) in
            if let error = error {
                guard let ckError = error as? CKError else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(error))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completionHandler(.failure(ckError))
                }
            } else {
                let cafe = Cafe(record: record!)
                DispatchQueue.main.async {
                    completionHandler(.success(cafe))
                }
            }
        }
    }
}
