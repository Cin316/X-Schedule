//
//  ScheduleTableController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/21/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit

public class ScheduleTableController: UITableViewController {
    
    public var schedule: Schedule = Schedule()
    
    private var internalCellColor: UIColor = UIColor(red: (0/255.0), green: (0/255.0), blue: (0/255.0), alpha: 0.0)
    private var internalHighlightedColor: UIColor = UIColor(red: (251.0/255.0), green: (250.0/255.0), blue: (146.0/255.0), alpha: 0.4)
    
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections, always 1.
        return 1
    }

    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section, the number of items in the schedule.
        return schedule.items.count
    }

    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScheduleTableCell", forIndexPath: indexPath) 
        let item = schedule.items[indexPath.row]
        
        // Configure the cell.
        if let subjectLabel = cell.viewWithTag(101) as? UILabel {
            subjectLabel.text = item.blockName.uppercaseString
        }
        if let timeLabel = cell.viewWithTag(102) as? UILabel {
            timeLabel.text = timeTextForScheduleItem(item)
        }
        
        return cell
    }
    private func timeTextForScheduleItem(item: ScheduleItem) -> String {
        let startString = timeTextForNSDate(item.startTime)
        let endString = timeTextForNSDate(item.endTime)
        let outputText = "\(startString) - \(endString)"
        
        return outputText
    }
    private func timeTextForNSDate(time: NSDate?) -> String {
        var timeText: String = ""
        let dateFormat: NSDateFormatter = NSDateFormatter()
        dateFormat.dateFormat = "h:mm"
        if let realTime = time {
            timeText = dateFormat.stringFromDate(realTime)
        } else {
            timeText = "?:??"
        }
        
        return timeText
    }
    
    public override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //Correctly colors the schedule table cells.
        let item = schedule.items[indexPath.row]
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        //Highlight the cell if the schedule is for today and the class is happening now.
        let isNow: Bool = calendar.isDateInToday(schedule.date) && isSceduleItemHappeningNow(item)
        
        if (isNow) {
            //Color is higlighted.
            cell.backgroundColor = highlightedColor()
        } else {
            //Fixes background color on iPad.
            //Color is transparent.
            cell.backgroundColor = cellColor()
        }
        
    }
    private func isSceduleItemHappeningNow(item: ScheduleItem) -> Bool {
        //Determine if right now is between the start and end of a ScheduleItem.
        var happeningNow: Bool = false
        if (item.startTime != nil && item.endTime != nil) {
            let afterStart: Bool = NSDate().compare(item.startTime!) != NSComparisonResult.OrderedAscending
            let beforeEnd: Bool = NSDate().compare(item.endTime!) != NSComparisonResult.OrderedDescending
            happeningNow = afterStart && beforeEnd
        }
        
        return happeningNow
    }
    
    public func cellColor() -> UIColor {
        return internalCellColor
    }
    public func highlightedColor() -> UIColor {
        return  internalHighlightedColor
    }
    
    public func displaySchedule(newSchedule: Schedule) {
        schedule = newSchedule
        self.tableView.reloadData()
    }
    
}
