//
//  ScheduleTableController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/21/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit

public class ScheduleTableController: UITableViewController {
    
    public var schedule: Schedule = Schedule(items: [])
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return schedule.items.count
    }

    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScheduleTableCell", forIndexPath: indexPath) as! UITableViewCell
        let item = schedule.items[indexPath.row]
        var dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "h:mm"
        
        // Configure the cell.
        if let subjectLabel = cell.viewWithTag(101) as? UILabel {
            subjectLabel.text = item.blockName.uppercaseString
        }
        if let timeLabel = cell.viewWithTag(102) as? UILabel {
            var startString = dateFormat.stringFromDate(item.startTime)
            var endString = dateFormat.stringFromDate(item.endTime)
            timeLabel.text = "\(startString) - \(endString)"
        }
        
        return cell
    }
    
    public override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //Fix background color on iPad.
        cell.backgroundColor = UIColor(red: (225.0/255.0), green: (238.0/255.0), blue: (254.0/255.0), alpha: 1.0)
    }
}
