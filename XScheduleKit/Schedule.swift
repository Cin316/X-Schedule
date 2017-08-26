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
    open var subtitle: String = ""
    open var date: Date = Date()
    
    open var manuallyMarkedUnusual: Bool = false
    
    public init() {
        
    }
    public init(items: [ScheduleItem]) {
        self.items = items
    }
    public init(items: [ScheduleItem], title: String) {
        self.items = items
        self.title = title
    }
    public init(items: [ScheduleItem], title: String, subtitle: String) {
        self.items = items
        self.title = title
        self.subtitle = subtitle
    }
}

public protocol ScheduleItem {
    func primaryText() -> String
    func secondaryText() -> String
    func isHappeningAt(time: Date) -> Bool
}

public protocol SubstitutableScheduleItem: ScheduleItem {
    var blockName: String { get set }
}

open class TimeSpanScheduleItem: SubstitutableScheduleItem {
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
    
    public func primaryText() -> String {
        return blockName
    }
    
    public func secondaryText() -> String {
        let startString = timeTextForNSDate(startTime as Date?)
        let endString = timeTextForNSDate(endTime as Date?)
        let outputText = "\(startString) - \(endString)"
        
        return outputText
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
    
    public func isHappeningAt(time: Date) -> Bool {
        //Determine if the given time is between the start and end of a ScheduleItem.
        var happeningNow: Bool = false
        if (startTime != nil && endTime != nil) {
            let afterStart: Bool = time.compare(startTime! as Date) != ComparisonResult.orderedAscending
            let beforeEnd: Bool = time.compare(endTime! as Date) != ComparisonResult.orderedDescending
            happeningNow = afterStart && beforeEnd
        }
        
        return happeningNow
    }
}

open class TimePointScheduleItem: SubstitutableScheduleItem {
    open var blockName: String = ""
    open var time: Date?
    
    public init(blockName: String) {
        self.blockName = blockName
    }
    public init(time: Date?) {
        self.time = time
    }
    public init(blockName: String, time: Date?) {
        self.blockName = blockName
        self.time = time
    }
    
    public func primaryText() -> String {
        return blockName
    }
    
    public func secondaryText() -> String {
        let timeString = timeTextForNSDate(time as Date?)
        
        return timeString
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
    
    public func isHappeningAt(time: Date) -> Bool {
        return false
    }
}

open class DescriptionScheduleItem: SubstitutableScheduleItem {
    open var blockName: String = ""
    
    public init(blockName: String) {
        self.blockName = blockName
    }
    
    public func primaryText() -> String {
        return blockName
    }
    
    public func secondaryText() -> String {
        return ""
    }
    
    public func isHappeningAt(time: Date) -> Bool {
        return false
    }
}
