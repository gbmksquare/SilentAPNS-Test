//
//  NotificationRecord.swift
//  SilentAPNS-Test
//
//  Created by 구범모 on 2015. 7. 21..
//  Copyright (c) 2015년 gbmKSquare. All rights reserved.
//

import Foundation
import RealmSwift

class NotificationRecord: Object {
    dynamic var identifier = ""
    dynamic var index = 0
    dynamic var sent = NSDate()
    dynamic var received = NSDate()
    dynamic var interval: Double = 0.0
    
    override class func indexedProperties() -> [String] {
        return ["identifier", "index"]
    }
}
