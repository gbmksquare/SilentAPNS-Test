//
//  NotificationOption.swift
//  SilentAPNS-Test
//
//  Created by 구범모 on 2015. 7. 21..
//  Copyright (c) 2015년 gbmKSquare. All rights reserved.
//

import Foundation

enum IntervalOption: Int {
    case minute1 = 60
    case minute5 = 300
    case minute10 = 600
    case minute30 = 1800
    case hour1 = 3600
    
    static let allValues = [minute1, minute5, minute10, minute30, hour1]
    
    static var allStrings: [String] {
        var strings = [String]()
        for option in IntervalOption.allValues {
            strings.append(option.prettyString)
        }
        return strings
    }
    
    var prettyString: String {
        switch self {
        case .minute1: return "1 minute"
        case .minute5: return "5 minutes"
        case .minute10: return "10 minutes"
        case .minute30: return "30 minutes"
        case .hour1: return "1 hour"
        }
    }
    
    static func optionFromString(string: String) -> IntervalOption {
        switch string {
        case "1 minute": return IntervalOption.minute1
        case "5 minutes": return IntervalOption.minute5
        case "10 minutes": return IntervalOption.minute10
        case "30 minutes": return IntervalOption.minute30
        case "1 hour": return IntervalOption.hour1
        default: return IntervalOption.minute1
        }
    }
}

enum CountOption: Int {
    case one = 1
    case five = 5
    case ten = 10
    case thirty = 30
    case fifty = 50
    case hundred = 100
    case threehundred = 300
    case fivehundred = 500
    case thousand = 1000
    
    static let allValues = [one, five, ten, thirty, fifty, hundred, threehundred, fivehundred, thousand]
    
    static var allStrings: [String] {
        var strings = [String]()
        for option in allValues {
            strings.append("\(option.rawValue)")
        }
        return strings
    }
    
    static func optionFromString(string: String) -> CountOption {
        let int = string.toInt()!
        return CountOption(rawValue: int)!
    }
}
