//
//  Schedule.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/17/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

public class Schedule {
    public var items: [ScheduleItem] = []
    public var title: String = ""
    public var date: NSDate = NSDate()
    
    public init() {
        
    }
    public init(items: [ScheduleItem]) {
        self.items = items
    }
    public init(items: [ScheduleItem], title: String) {
        self.items = items
        self.title = title
    }
}

public class ScheduleItem {
    public var blockName: String = ""
    public var startTime: NSDate = NSDate()
    public var endTime: NSDate = NSDate()
    
    public init(blockName: String) {
        self.blockName = blockName
    }
    public init(startTime: NSDate, endTime: NSDate) {
        self.startTime = startTime
        self.endTime = endTime
    }
    public init(blockName: String, startTime: NSDate, endTime: NSDate) {
        self.blockName = blockName
        self.startTime = startTime
        self.endTime = endTime
    }
}
