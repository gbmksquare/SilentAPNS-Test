//
//  MainViewController.swift
//  SilentAPNS-Test
//
//  Created by 구범모 on 2015. 7. 21..
//  Copyright (c) 2015년 gbmKSquare. All rights reserved.
//

import UIKit
import RealmSwift
import NWPusher

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var deviceTokenLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var realmToken: NotificationToken?
    
    // Model
    var trialResults: Results<TrialRecord>?
    
    var pusher: NWPusher?

    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "APNS Test"
        listenForAPNSRegisteredNotification()
        listenForRealmChange()
        refreshData()
        createPusher()
    }
    
    deinit {
        stopListeningForAPNSRegisteredNotification()
        stopListeningForRealmChange()
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "detailSegue":
                let trial = trialResults![tableView.indexPathForSelectedRow()!.row]
                let destinationViewController = segue.destinationViewController as! DetailViewController
                destinationViewController.trial = trial
                destinationViewController.pusher = pusher
            default: break
            }
        }
    }
    
    // MARK: Pusher
    private func createPusher() {
        // Load certificate
        //!!!: Password here
        let certificate: String
        let password: String
        #if DEBUG
            certificate = "development.p12"
            password = ""
            #else
            certificate = "distribution.p12"
            password = ""
        #endif
        
        if let url = NSBundle.mainBundle().URLForResource(certificate, withExtension: nil) {
            let data = NSData(contentsOfURL: url)
            var error: NSError?
            // Create pusher
            pusher = NWPusher.connectWithPKCS12Data(data, password: password, error: &error)
            // Retry if hand shake failure
            if pusher == nil {
                createPusher()
            }
        } else {
            UIAlertView(title: "Error", message: "No certificate found.", delegate: nil, cancelButtonTitle: "Confirm").show()
        }
    }
    
    // MARK: Data
    private func getTrialsData() {
        trialResults = Realm().objects(TrialRecord)
    }
    
    private func listenForRealmChange() {
        realmToken = Realm().addNotificationBlock { (notification, realm) -> Void in
            self.refreshData()
        }
    }
    
    private func stopListeningForRealmChange() {
        if let realmToken = realmToken {
            Realm().removeNotification(realmToken)
        }
    }
    
    @IBAction func removeAllData(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Remove all data?", message: nil, preferredStyle: .Alert)
        let deleteAction = UIAlertAction(title: "Confirm", style: .Destructive) { (_) -> Void in
            Realm().write { () -> Void in
                Realm().deleteAll()
            }
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "identifier")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: Table view
    private func refreshData() {
        getTrialsData()
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trialResults?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let trial = trialResults![indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MainCell
        cell.identifierLabel.text = "Trial \(trial.identifier)"
        cell.intervalLabel.text = IntervalOption(rawValue: trial.interval)?.prettyString
        cell.countLabel.text = "\(trial.count)"
        cell.sentLabel.text = "\(trial.sent)"
        cell.receivedLabel.text = "\(trial.received)"
        if trial.sent != 0 {
            cell.percentageLabel.text = "\(Int(round(Double(trial.received) / Double(trial.sent) * 100)))%"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK: Notification
    private func listenForAPNSRegisteredNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleAPNSRegistered:", name: "APNSRegisteredNotification", object: nil)
    }
    
    private func stopListeningForAPNSRegisteredNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func handleAPNSRegistered(notification: NSNotification) {
        if let token = notification.userInfo?["token"] as? String {
            deviceTokenLabel.text = token
        } else {
            deviceTokenLabel.text = "Device token not available."
        }
    }
}
