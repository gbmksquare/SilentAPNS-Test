//
//  AppDelegate.swift
//  SilentAPNS-Test
//
//  Created by 구범모 on 2015. 7. 12..
//  Copyright (c) 2015년 gbmKSquare. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        registerDefaults()
        registerForNotifications()
        return true
    }
    
    private func registerDefaults() {
        NSUserDefaults.standardUserDefaults().registerDefaults(["identifier": 1])
    }

    // MARK: Register for notification
    private func registerForNotifications() {
        let settings = UIUserNotificationSettings(forTypes: (.Alert | .Sound | .Badge), categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        println("Registered user notificaitons.")
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let token = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>")).stringByReplacingOccurrencesOfString(" ", withString: "", options: .allZeros, range: nil)
        println("Registered remote notifications with token: \(token).")
        
        // Save token
        NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // Notification
        let userInfo = ["token": token]
        NSNotificationCenter.defaultCenter().postNotificationName("APNSRegisteredNotification", object: self, userInfo: userInfo)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("Failed to register remote notifications with error: \(error).")
        
        let alert = UIAlertController(title: "Error", message: "Failed to register notifications.", preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "Confirm", style: .Default) { (_) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(cancel)
        application.keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: Received remote notifications
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        println("Received a remote notification: \(userInfo)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        println("Received a remote notification with completion handler: \(userInfo)")
        
        let identifier = userInfo["userInfo"]!["identifier"] as! Int
        let index = userInfo["userInfo"]!["index"] as! Int
        let firedString = userInfo["userInfo"]!["timestamp"] as! String
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let fired = formatter.dateFromString(firedString)!
        
        // Create record
        let record = NotificationRecord()
        record.identifier = "\(identifier)"
        record.index = index
        record.sent = fired
        record.received = NSDate()
        record.interval = record.received.timeIntervalSinceDate(record.sent)
        
        // Update record
        let trialRecord = Realm().objects(TrialRecord).filter("identifier == %@", record.identifier).first!
        
        // Save record
        Realm().write { () -> Void in
            Realm().add(record, update: false)
            trialRecord.received++
        }
        
        completionHandler(.NoData)
    }
}

