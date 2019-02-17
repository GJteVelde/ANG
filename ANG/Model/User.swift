//
//  User.swift
//  ANG
//
//  Created by Gerjan te Velde on 17/02/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation

struct CurrentUser {

    static var name: String = ""
    
    static func isAuthorized() -> Bool {
        if CurrentUser.name.isEmpty {
            return false
        } else {
            return true
        }
    }
}
