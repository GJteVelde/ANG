//
//  GenericIdentifier.swift
//  ANG
//
//  Created by Gerjan te Velde on 13/05/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation
import CloudKit

struct GenericIdentifier<T>: Hashable, Equatable {
    var recordId: CKRecord.ID
    
    init(recordId: CKRecord.ID) {
        self.recordId = recordId
    }
}
