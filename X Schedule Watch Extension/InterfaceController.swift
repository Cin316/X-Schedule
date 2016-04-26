//
//  InterfaceController.swift
//  X Schedule Watch Extension
//
//  Created by Nicholas Reichert on 4/19/16.
//  Copyright © 2016 Nicholas Reichert. All rights reserved.
//

import WatchKit
import Foundation
import XScheduleKitWatch

class InterfaceController: WKInterfaceController {

    @IBOutlet var scheduleTable: WKInterfaceTable!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        //TODO Display schedule date and title.
        let testSchedule = Schedule()
        testSchedule.title = "Late A Day"
        testSchedule.items.append(ScheduleItem(blockName: "A", startTime: NSDate(timeIntervalSinceNow: -5*3600), endTime: NSDate(timeIntervalSinceNow: -4*3600)))
        testSchedule.items.append(ScheduleItem(blockName: "B", startTime: NSDate(timeIntervalSinceNow: -4*3600), endTime: NSDate(timeIntervalSinceNow: -3*3600)))
        testSchedule.items.append(ScheduleItem(blockName: "Assembly", startTime: nil, endTime: nil))
        testSchedule.items.append(ScheduleItem(blockName: "C", startTime: NSDate(timeIntervalSinceNow: -1*3600), endTime: NSDate(timeIntervalSinceNow: -0*3600)))
        testSchedule.items.append(ScheduleItem(blockName: "FLEX", startTime: NSDate(timeIntervalSinceNow: 0*3600), endTime: NSDate(timeIntervalSinceNow: 1*3600)))
        
        displaySchedule(testSchedule)
        
        // Configure interface objects here.
    }
    
    func displaySchedule(schedule: Schedule) {
        titleLabel.setText(schedule.title)
        scheduleTable.setNumberOfRows(schedule.items.count, withRowType: "scheduleTableRow")
        for i in 0...schedule.items.count-1 {
            let item = schedule.items[i]
            let row = scheduleTable.rowControllerAtIndex(i) as? ScheduleTableRow
            
            var size: CGFloat = 0.0
            if (item.blockName.characters.count <= 1) {
                size = 22.0
            } else {
                size = 16.0
            }
            let font = UIFont.boldSystemFontOfSize(size)
            let fontAttrs = [NSFontAttributeName : font]
            row?.classLabel.setAttributedText(NSAttributedString(string: item.blockName, attributes: fontAttrs))
            
            row?.startTime.setText(timeTextForNSDate(item.startTime))
            row?.endTime.setText(timeTextForNSDate(item.endTime))
        }
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

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
