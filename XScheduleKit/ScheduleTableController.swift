//
//  ScheduleTableController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/21/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit

open class ScheduleTableController: UITableViewController {
    
    open var schedule: Schedule = Schedule()
    
    private var internalCellColor: UIColor = UIColor(red: (0/255.0), green: (0/255.0), blue: (0/255.0), alpha: 0.0)
    private var internalHighlightedColor: UIColor = UIColor(red: (251.0/255.0), green: (250.0/255.0), blue: (146.0/255.0), alpha: 0.4)
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections, always 1.
        return 1
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section, the number of items in the schedule.
        return schedule.items.count
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableCell", for: indexPath) 
        let item = schedule.items[indexPath.row]
        
        // Configure the cell.
        if let subjectLabel = cell.viewWithTag(101) as? UILabel {
            subjectLabel.text = item.primaryText().uppercased()
        }
        if let timeLabel = cell.viewWithTag(102) as? UILabel {
            timeLabel.text = item.secondaryText()
        }
        
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //Correctly colors the schedule table cells.
        let item = schedule.items[indexPath.row]

        let shouldBeHighlighted: Bool = item.isHappeningAt(time: Date())
        
        if (shouldBeHighlighted) {
            //Color is higlighted.
            cell.backgroundColor = highlightedColor()
        } else {
            //Fixes background color on iPad.
            //Color is transparent.
            cell.backgroundColor = cellColor()
        }
        
    }
    
    open func cellColor() -> UIColor {
        return internalCellColor
    }
    open func highlightedColor() -> UIColor {
        return  internalHighlightedColor
    }
    
    open func displaySchedule(_ newSchedule: Schedule) {
        schedule = newSchedule
        self.tableView.reloadData()
    }
    
}
