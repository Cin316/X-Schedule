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
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        scheduleTable.setNumberOfRows(10, withRowType: "scheduleTableRow")
        let row = scheduleTable.rowControllerAtIndex(0) as? ScheduleTableRow
        row?.classLabel.setText("B    ") //4 spaces afterwards for spacing.
        
        // Configure interface objects here.
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
