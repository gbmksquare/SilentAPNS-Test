//
//  ViewController.swift
//  SilentAPNS-Test
//
//  Created by 구범모 on 2015. 7. 12..
//  Copyright (c) 2015년 gbmKSquare. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var deviceTokenLabel: UILabel!
    var token: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        listenForAPNSRegisteredNotification()
    }
    
    deinit {
        stopListeningForAPNSRegisteredNotification()
    }
    
    
    // Observer
    private func listenForAPNSRegisteredNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleAPNSRegisteredNotification:", name: "APNSRegisteredNotification", object: nil)
    }
    
    private func stopListeningForAPNSRegisteredNotification() {
        
    }
    
    @objc private func handleAPNSRegisteredNotification(notification: NSNotification) {
        if let token = notification.userInfo?["token"] as? String {
            deviceTokenLabel.text = token
            self.token = token
        } else {
            deviceTokenLabel.text = "No Device Token"
        }
    }
    
    // Share
    @IBAction func tappedShareButton(sender: UIBarButtonItem) {
        if let token = token {
            let itemToShare = [token]
            let activityViewController = UIActivityViewController(activityItems: itemToShare, applicationActivities: nil)
            presentViewController(activityViewController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Error", message: "No token found.", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (_) -> Void in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(cancelAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func tappedTrashButton(sender: UIButton) {
        Realm().write { () -> Void in
            Realm().deleteAll()
        }
    }
}

