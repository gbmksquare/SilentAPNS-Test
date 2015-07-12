//
//  NotificationRecord.swift
//  SilentAPNS-Test
//
//  Created by 구범모 on 2015. 7. 12..
//  Copyright (c) 2015년 gbmKSquare. All rights reserved.
//

import Foundation
import RealmSwift

class NotificationRecord: Object {
    dynamic var title = ""
    dynamic var identifier = ""
    dynamic var recieved = NSDate()
}
