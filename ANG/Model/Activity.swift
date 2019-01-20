//
//  Activity.swift
//  ANG
//
//  Created by Gerjan te Velde on 15/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation

struct Activity {
    var title: String
    var location: String
    var cafe: String
    
    init(title: String, location: String, cafe: String) {
        self.title = title
        self.location = location
        self.cafe = cafe
        Activities.all.append(self)
    }
}

struct Activities {
    static var all = [Activity]()
    
    //Return activities related to a specific cafe.
    static func ofCafe(_ cafe: String) -> [Activity] {
        var activities: [Activity] = []
        
        for activity in Activities.all {
            if activity.cafe == cafe {
                activities.append(activity)
            }
        }
        
        return activities
    }
}
