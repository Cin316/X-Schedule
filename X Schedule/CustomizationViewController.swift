//
//  CustomizationViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 6/9/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit
import XScheduleKit

class CustomizationViewController: UITableViewController {
    
    var substitutions: [(block: String, className: String)] = SubstitutionManager.loadSubstitutions()
    
    override func viewDidLoad() {
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections, always 1.
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section, the number of items in the schedule.
        return substitutions.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomizationCell", forIndexPath: indexPath) as! UITableViewCell
        let item = substitutions[indexPath.row]
        
        // Configure the cell.
        if let blockLabel = cell.viewWithTag(501) as? UILabel {
            blockLabel.text = item.block
        }
        if let classLabel = cell.viewWithTag(502) as? UILabel {
            classLabel.text = item.className
        }
        
        return cell
    }
    
}