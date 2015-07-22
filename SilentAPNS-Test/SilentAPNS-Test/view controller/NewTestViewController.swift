//
//  NewTestViewController.swift
//  SilentAPNS-Test
//
//  Created by 구범모 on 2015. 7. 21..
//  Copyright (c) 2015년 gbmKSquare. All rights reserved.
//

import UIKit
import XLForm
import RealmSwift

class NewTestViewController: XLFormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Trial"
        setupForm()
    }
    
    // MARK: Action
    @IBAction func tappedAddButton(sender: UIBarButtonItem) {
        let values = formValues()
        let interval = IntervalOption.optionFromString(values["interval"] as! String)
        let count = CountOption.optionFromString(values["count"] as! String)
        
        var lastIdentifier = NSUserDefaults.standardUserDefaults().integerForKey("identifier")
        
        let trial = TrialRecord()
        trial.identifier = "\(lastIdentifier)"
        trial.interval = interval.rawValue
        trial.count = count.rawValue
        trial.started = NSDate()
        
        Realm().write { () -> Void in
            Realm().add(trial, update: true)
        }
        
        // Update identifier
        NSUserDefaults.standardUserDefaults().setInteger(++lastIdentifier, forKey: "identifier")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func tappedCancelButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Form
    private func setupForm() {
        let form = XLFormDescriptor(title: "New Trial")
        let section = XLFormSectionDescriptor.formSectionWithTitle("Settings")
        var row: XLFormRowDescriptor
        
        self.form = form
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag: "interval", rowType: XLFormRowDescriptorTypeSelectorPickerViewInline)
        row.required = true
        row.title = "Interval"
        row.value = IntervalOption.minute10.prettyString
        row.selectorOptions = IntervalOption.allStrings
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "count", rowType: XLFormRowDescriptorTypeSelectorPickerViewInline)
        row.required = true
        row.title = "Count"
        row.value = "\(CountOption.ten.rawValue)"
        row.selectorOptions = CountOption.allStrings
        section.addFormRow(row)
    }
}
