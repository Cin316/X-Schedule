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
    
    var selectedNum: Int = 0
    var selectedItem: (block: String, className: String) = ("","")
    
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell: UITableViewCell? = tableView.cellForRowAtIndexPath(indexPath)
        var substitution: (block: String, className: String) = substitutions[indexPath.row]
        selectedItem = substitution
        selectedNum = indexPath.row
        
        self.performSegueWithIdentifier("subDetail", sender: self)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let newSub = segue.destinationViewController as? NewSubViewController {
            if (segue.identifier == "subDetail") {
                newSub.substitution = selectedItem
            } else if (segue.identifier == "newSub") {
                newSub.substitution = ("","")
            }
        }
    }
}

class NewSubViewController: UITableViewController {

    @IBOutlet weak var blockName: UITextField!
    @IBOutlet weak var className: UITextField!
    
    var substitution: (block: String, className: String) = ("","")
    
    override func viewDidLoad() {
        loadSubstitution()
    }
    
    func loadSubstitution() {
        blockName.text = substitution.block
        className.text = substitution.className
    }
    
}