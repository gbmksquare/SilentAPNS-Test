//
//  TrialRecord.swift
//  SilentAPNS-Test
//
//  Created by 구범모 on 2015. 7. 21..
//  Copyright (c) 2015년 gbmKSquare. All rights reserved.
//

import Foundation
import RealmSwift

class TrialRecord: Object {
    dynamic var identifier = ""
    
    dynamic var interval = 0
    dynamic var count = 0
    dynamic var started = NSDate()
    
    dynamic var sent = 0
    dynamic var received = 0
    
    override class func primaryKey() -> String? {
        return "identifier"
    }
}
