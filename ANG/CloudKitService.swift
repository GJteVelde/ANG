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
    
    func fetchAllRegions(completionHandler: @escaping ((Result<[Region], Error>) -> Void)) {
        DispatchQueue.global().async {
            var regions = [Region]()
            
            let predicate = NSPredicate(value: true)
            let regionQuery = CKQuery(recordType: Region.recordType, predicate: predicate)
            
            self.publicDatabase.perform(regionQuery, inZoneWith: nil) { (ckRecords, error) in
                if let ckError = error as? CKError {
                    DispatchQueue.main.async {
                        completionHandler(.failure(ckError))
                    }
                } else {
                    for ckRecord in ckRecords! {
                        let regionID = ckRecord.recordID
                        guard let name = ckRecord.value(forKey: "Name") as? String else { continue }
                        guard let province = ckRecord.value(forKey: "Province") as? String else { continue }
                        
                        let newRegion = Region(regionID: regionID, name: name, province: province)
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
