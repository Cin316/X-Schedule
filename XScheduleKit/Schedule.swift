//
//  Schedule.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/17/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

open class Schedule {
    open var items: [ScheduleItem] = []
    open var title: String = ""
    open var date: Date = Date()
    
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

open class ScheduleItem {
    open var blockName: String = ""
    open var startTime: Date?
    open var endTime: Date?
    
    public init(blockName: String) {
        self.blockName = blockName
    }
    public init(startTime: Date?, endTime: Date?) {
        self.startTime = startTime
        self.endTime = endTime
    }
    public init(blockName: String, startTime: Date?, endTime: Date?) {
        self.blockName = blockName
        self.startTime = startTime
        self.endTime = endTime
    }
}
