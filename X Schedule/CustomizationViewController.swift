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
    
    static let substitutionsKey: String = "substitutions"
    
    var substitutions: [(block: String, className: String)] = []
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomizatioinCell", forIndexPath: indexPath) as! UITableViewCell
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
    
    class func saveSubstitutions(subs: [(block: String, className: String)]) {
        var arrayVersion: [[String]] = convertTupleToArray(subs)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(arrayVersion, forKey: substitutionsKey)
    }
    private class func convertTupleToArray(tuple: [(block: String, className: String)]) -> [[String]] {
        var output: [[String]] = [[]]
        for item in tuple {
            var tmpArray = ["",""]
            tmpArray[0] = item.block
            tmpArray[1] = item.className
            output.append(tmpArray)
        }
        
        return output
    }
    private class func convertArrayToTuple(array: [[String]]) -> [(block: String, className: String)] {
        var output: [(block: String, className: String)] = []
        for item in array {
            output.append(block: item[0], className: item[1])
        }
        
        return output
    }
    class func loadSubstitutions() -> [(block: String, className: String)] {
        let defaults = NSUserDefaults.standardUserDefaults()
        var object: AnyObject? = defaults.objectForKey(substitutionsKey)
        
        var tupleVersion: [(block: String, className: String)] = []
        if let array = object as? [[String]] {
            tupleVersion = convertArrayToTuple(array)
            
        }
        
        return tupleVersion
    }
}