//
//  ColoredScheduleTableController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 4/14/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

import UIKit

public class ColoredScheduleTableController: ScheduleTableController {
    
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
            //Color is yellow.
            cell.backgroundColor = UIColor(red: (251.0/255.0), green: (250.0/255.0), blue: (146.0/255.0), alpha: 1.0)
        } else {
            //Fix background color on iPad.
            //Color is blue.
            cell.backgroundColor = UIColor(red: (225.0/255.0), green: (238.0/255.0), blue: (254.0/255.0), alpha: 1.0)
        }
        
    }
}
