//
//  Schedule.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/17/15.
//  Copyright (c) 2015 Nicholas Reichert. All rights reserved.
//

import Foundation

class Schedule {
    var items: [ScheduleItem] = []
    
    init(items: [ScheduleItem]) {
        self.items = items
    }
}

class ScheduleItem {
    var blockName: String = ""
    var startTime: NSDate = NSDate()
    var endTime: NSDate = NSDate()
    
    init(blockName: String) {
        self.blockName = blockName
    }
    init(startTime: NSDate, endTime: NSDate) {
        self.startTime = startTime
        self.endTime = endTime
    }
    init(blockName: String, startTime: NSDate, endTime: NSDate) {
        self.blockName = blockName
        self.startTime = startTime
        self.endTime = endTime
    }
}