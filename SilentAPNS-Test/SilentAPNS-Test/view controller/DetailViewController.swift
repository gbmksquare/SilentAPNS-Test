//
//  DetailViewController.swift
//  SilentAPNS-Test
//
//  Created by 구범모 on 2015. 7. 21..
//  Copyright (c) 2015년 gbmKSquare. All rights reserved.
//

import UIKit
import RealmSwift
import NWPusher

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var sentLabel: UILabel!
    @IBOutlet weak var receivedLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var startBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // Model
    var trial: TrialRecord!
    var index = 0
    var timer: NSTimer?
    var pusher: NWPusher!
    
    var realmToken: NotificationToken?
    
    var notificationResults: Results<NotificationRecord>?
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Trial \(trial.identifier)"
        populateData()
        listenForRealmChange()
    }
    
    deinit {
        stopListeningForRealmChange()
    }
    
    // MARK: Action
    @IBAction func startTrial(sender: UIBarButtonItem) {
        if sender.title == "Start" {
            startBarButtonItem.title = "Halt"
            navigationItem.setHidesBackButton(true, animated: true)
            
            // Schedule timer
            let fireInterval = NSTimeInterval(Double(trial.interval / trial.count))
            timer = NSTimer.scheduledTimerWithTimeInterval(fireInterval, target: self, selector: "sendNotification", userInfo: nil, repeats: true)
            timer?.fire()
        } else {
            finishTimer()
        }
    }
    
    // MARK: Data
    private func populateData() {
        identifierLabel.text = "Trial \(trial.identifier)"
        descriptionLabel.text = "Sending \(trial.count) notifications in \(IntervalOption(rawValue: trial.interval)!.prettyString)."
        refreshData()
    }
    
    private func getNotificationData() {
        notificationResults = Realm().objects(NotificationRecord).filter("identifier == %@", trial.identifier)
    }
    
    private func refreshData() {
        sentLabel.text = "\(trial.sent)"
        receivedLabel.text = "\(trial.received)"
        if trial.sent != 0 {
            percentageLabel.text = "\(Int(round(Double(trial.received) / Double(trial.sent) * 100)))%"
            progressView.setProgress(Float(Double(trial.received) / Double(trial.sent)), animated: true)
        }
        getNotificationData()
        tableView.reloadData()
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
    
    // MARK: Remote notification
    @objc private func sendNotification() {
        // Payload
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let currentDate = formatter.stringFromDate(date)
        let payload = "{\"aps\":{\"content-available\": 1}, \"userInfo\":{\"identifier\": \(trial.identifier), \"index\": \(index), \"timestamp\": \"\(currentDate)\"}}"
        
        // Push notification
        let token = NSUserDefaults.standardUserDefaults().stringForKey("token")
        var error: NSError?
        pusher.pushPayload(payload, token: token, identifier: 0, error: &error)
        
        // Update record
        let trialRecord = Realm().objects(TrialRecord).filter("identifier == %@", self.trial.identifier).first!

        // Save record
        Realm().write { () -> Void in
            trialRecord.sent++
        }
        
        // Check APNS success
//        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
//        dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
//            var identifier: UInt = 0
//            var error: NSError?
//            var apnError: NSError?
//            let read = self.pusher.readFailedIdentifier(&identifier, apnError: &apnError, error: &error)
//            if read == true && apnError != nil {
//                println("Notificaiton rejected.")
//            } else if read == true {
//                println("Notification sent.")
//                
//                // Update record
//                let trialRecord = Realm().objects(TrialRecord).filter("identifier == %@", self.trial.identifier).first!
//                
//                // Save record
//                Realm().write { () -> Void in
//                    trialRecord.sent++
//                }
//            } else {
//                println("Notification failed to send.")
//            }
//        })
        
        // Prepare for next notification
        index++
        if index == trial.count {
            finishTimer()
        }
    }
    
    func finishTimer() {
        index = 0
        timer?.invalidate()
        timer = nil
        
        startBarButtonItem.title = "Start"
        navigationItem.setHidesBackButton(false, animated: true)
        
        UIAlertView(title: "Done", message: "Trial has ended.", delegate: nil, cancelButtonTitle: "Confirm").show()
    }
    
    // MARK: Table
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 5 }
        else { return notificationResults?.count ?? 0 }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "Summary" }
        else { return "Notifications" }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("notificationCell", forIndexPath: indexPath) as! UITableViewCell
            switch indexPath.row {
            case 0:
                let count = notificationResults?.filter("interval < 2").count ?? 0
                cell.textLabel?.text = "0 ~ 1 second"
                cell.detailTextLabel?.text = "\(count)"
            case 1:
                let count = notificationResults?.filter("interval < 6 && interval >= 2").count ?? 0
                cell.textLabel?.text = "2 ~ 5 seconds"
                cell.detailTextLabel?.text = "\(count)"
            case 2:
                let count = notificationResults?.filter("interval < 31 && interval >= 6").count ?? 0
                cell.textLabel?.text = "5 ~ 30 seconds"
                cell.detailTextLabel?.text = "\(count)"
            case 3:
                let count = notificationResults?.filter("interval < 61 && interval >= 31").count ?? 0
                cell.textLabel?.text = "0.5 ~ 1 minute"
                cell.detailTextLabel?.text = "\(count)"
            case 4:
                let count = notificationResults?.filter("interval >= 61").count ?? 0
                cell.textLabel?.text = "above 1 minute"
                cell.detailTextLabel?.text = "\(count)"
            default: break
            }
            return cell
        } else {
            let notification = notificationResults![indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("notificationCell", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = "Notification \(notification.index)"
            cell.detailTextLabel?.text = "\(Int(notification.interval))"
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
