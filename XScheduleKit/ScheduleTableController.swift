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
    
    private var internalCellColor: UIColor = UIColor(red: (0/255.0), green: (0/255.0), blue: (0/255.0), alpha: 0.0)
    private var internalHighlightedColor: UIColor = UIColor(red: (251.0/255.0), green: (250.0/255.0), blue: (146.0/255.0), alpha: 0.4)
    
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
        
        //If class is happening right now, make it yellow.
        let item = schedule.items[indexPath.row]
        var isNow: Bool = false
        //If schedule date is today.
        if (NSCalendar.currentCalendar().isDateInToday(schedule.date)) {
            //Check if class is happening now.
            if ((NSDate().compare(item.startTime) != NSComparisonResult.OrderedAscending) && (NSDate().compare(item.endTime) != NSComparisonResult.OrderedDescending)) {
                //Set background color to yellow
                isNow = true
            }
        }
        
        if (isNow) {
            //Color is higlighted.
            cell.backgroundColor = highlightedColor()
        } else {
            //Fix background color on iPad.
            //Color is transparent.
            cell.backgroundColor = cellColor()
        }
        
    }
    
    public func cellColor() -> UIColor {
        return internalCellColor
    }
    public func highlightedColor() -> UIColor {
        return  internalHighlightedColor
    }
    
}
