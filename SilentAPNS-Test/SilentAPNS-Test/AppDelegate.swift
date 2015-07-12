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
        
        // Register notification
        registerForNotifications()
        
        return true
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
        let token = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        println("Registered remote notifications with token: \(token).")
        
        let userInfo = ["token": token]
        NSNotificationCenter.defaultCenter().postNotificationName("APNSRegisteredNotification", object: self, userInfo: userInfo)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("Failed to register remote notifications with error: \(error).")
    }
    
    // MARK: Received remote notifications
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        println("Received a remote notification: \(userInfo)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        println("Received a remote notification with completion handler: \(userInfo)")
        
        // Save record
        let record = NotificationRecord()
        record.title = userInfo["aps"]?["alert"] as! String
        record.identifier = userInfo["identifier"] as! String
        
        Realm().write { () -> Void in
            Realm().add(record, update: false)
        }
        
        completionHandler(.NoData)
    }
}

