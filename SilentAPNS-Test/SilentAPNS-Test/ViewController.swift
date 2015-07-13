//
//  ViewController.swift
//  SilentAPNS-Test
//
//  Created by 구범모 on 2015. 7. 12..
//  Copyright (c) 2015년 gbmKSquare. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var deviceTokenLabel: UILabel!
    var token: String?
    
    @IBOutlet weak var tableView: UITableView!
    var records: Results<NotificationRecord>?
    var realmToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        listenForAPNSRegisteredNotification()
        listenForRealmChange()
        refreshTable()
    }
    
    deinit {
        stopListeningForAPNSRegisteredNotification()
    }
    
    
    // Observer
    private func listenForAPNSRegisteredNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleAPNSRegisteredNotification:", name: "APNSRegisteredNotification", object: nil)
    }
    
    private func stopListeningForAPNSRegisteredNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func handleAPNSRegisteredNotification(notification: NSNotification) {
        if let token = notification.userInfo?["token"] as? String {
            deviceTokenLabel.text = token
            self.token = token
        } else {
            deviceTokenLabel.text = "No Device Token"
        }
    }
    
    private func listenForRealmChange() {
        realmToken = Realm().addNotificationBlock { (notification, realm) -> Void in
            self.refreshTable()
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
    
    // MARK: Table
    private func refreshTable() {
        records = Realm().objects(NotificationRecord)
        self.tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        
        var identifier: String?
        switch indexPath.row {
        case 0: identifier = "10_per_1_min"
        case 1: identifier = "50_per_1_min"
        case 2: identifier = "100_per_1_min"
        case 3: identifier = "10_per_1_hour"
        case 4: identifier = "50_per_1_hour"
        case 5: identifier = "100_per_1_hour"
        default: break
        }
        
        if let identifier = identifier {
            cell.textLabel?.text = identifier
            
            if let results = records?.filter("identifier == %@", identifier) {
                cell.detailTextLabel?.text = "\(results.count)"
            } else {
                cell.detailTextLabel?.text = "0"
            }
        }
        
        return cell
    }
}

