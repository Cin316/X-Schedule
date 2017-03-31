//
//  InterfaceController.swift
//  X Schedule Watch Extension
//
//  Created by Nicholas Reichert on 4/19/16.
//  Copyright © 2016 Nicholas Reichert.
//

import WatchKit
import Foundation
import XScheduleKitWatch

class InterfaceController: WKInterfaceController {

    @IBOutlet var scheduleTable: WKInterfaceTable!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let testSchedule = Schedule()
        testSchedule.title = "Loading"
        //TODO Add support for weekends/no classes.
        displaySchedule(testSchedule)
        
        XScheduleManager.getScheduleForToday( { (schedule: Schedule) in
            self.displaySchedule(schedule);
        })
    }
    
    func displaySchedule(_ schedule: Schedule) {
        titleLabel.setText(schedule.title)
        scheduleTable.setNumberOfRows(schedule.items.count, withRowType: "scheduleTableRow")
        for i in 0..<schedule.items.count {
            let item = schedule.items[i]
            let row = scheduleTable.rowController(at: i) as? ScheduleTableRow
            
            var size: CGFloat = 0.0
            if (item.primaryText().characters.count <= 1) {
                size = 22.0
            } else {
                size = 16.0
            }
            let font = UIFont.boldSystemFont(ofSize: size)
            let fontAttrs = [NSFontAttributeName : font]
            row?.classLabel.setAttributedText(NSAttributedString(string: item.primaryText().uppercased(), attributes: fontAttrs))
            
            // TODO Fix this. Times are broken on the watchOS app with Schedule class changes.
            //row?.startTime.setText(timeTextForNSDate(item.startTime))
            //row?.endTime.setText(timeTextForNSDate(item.endTime))
        }
        if (schedule.title=="" && schedule.items.count==0) {
            titleLabel.setText("No classes")
        }
    }
    private func timeTextForNSDate(_ time: Date?) -> String {
        var timeText: String = ""
        let dateFormat: DateFormatter = DateFormatter()
        dateFormat.dateFormat = "h:mm"
        if let realTime = time {
            timeText = dateFormat.string(from: realTime)
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
