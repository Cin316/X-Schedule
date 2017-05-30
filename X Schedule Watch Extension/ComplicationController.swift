//
//  ComplicationController.swift
//  X Schedule Watch Extension
//
//  Created by Nicholas Reichert on 4/19/16.
//  Copyright © 2016 Nicholas Reichert.
//

import ClockKit
import XScheduleKitWatch

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // TODO Stop using deprecated methods here.
    
    var schedule: Schedule!
    var scheduleTimes: [(blockName: String, time: Date)] = []
    
    override init() {
        super.init()
        XScheduleManager.getScheduleForToday( { (schedule: Schedule) in
            self.schedule = schedule
            self.scheduleTimes = self.scheduleToArray(schedule)
        })
    }
    private func scheduleToArray(_ schedule: Schedule) -> [(blockName: String, time: Date)] {
        var array: [(blockName: String, time: Date)] = []
        for item in schedule.items {
            if let spanItem = item as? TimeSpanScheduleItem {
                if let time = spanItem.startTime {
                    array.append((blockName: spanItem.blockName, time: time))
                }
                if let time = spanItem.endTime {
                    array.append((blockName: spanItem.blockName, time: time))
                }
            } else if let pointItem = item as? TimePointScheduleItem {
                if let time = pointItem.time {
                    array.append((blockName: pointItem.blockName, time: time))
                }
            }
        }
        array.sort {
            $0.time < $1.time
        }
        
        return array
    }
    
    // MARK: - Timeline Configuration
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        if (scheduleTimes.count > 0) {
            handler(scheduleTimes.first?.time)
        } else {
            handler(nil)
        }
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        if (scheduleTimes.count > 0) {
            handler(scheduleTimes.last?.time)
        } else {
            handler(nil)
        }
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    // TODO Support ALL the edge cases.
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        handler(getTimelineEntryForDate(complication, date: Date()))
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        var templates: [CLKComplicationTimelineEntry] = []
        let array = scheduleToArray(schedule)
        var index: Int = 0;
        
        while templates.count <= limit && date <= array[index].time && index < array.count { // `date <= array[index].time` may be causing incorrect behavior.
            templates.append(getTimelineEntryForDate(complication, date: array[index].time)!)
            index += 1
        }
        
        handler(templates)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        var templates: [CLKComplicationTimelineEntry] = []
        let array = scheduleToArray(schedule)
        var index: Int = 0;
        
        //Find first item.
        for item in array {
            if (item.time < date) {
                break;
            }
            index += 1
        }
        
        while templates.count <= limit && index < array.count {
            templates.append(getTimelineEntryForDate(complication, date: array[index].time)!)
            index += 1
        }
        
        handler(templates)
    }
    
    private func getTimelineEntryForDate(_ complication: CLKComplication, date: Date) -> CLKComplicationTimelineEntry? {
        let template = getComplicationTemplateForDate(complication, date: date)
        let startTime = getStartTimeForTime(date)
        if template != nil && startTime != nil {
            return CLKComplicationTimelineEntry(date: startTime!, complicationTemplate: template!)
        } else {
            return nil
        }
    }
    private func getStartTimeForTime(_ date: Date) -> Date? {
        if scheduleTimes.count > 0 {
            if date < scheduleTimes.first!.time {
                return date
            }
            for i in 1..<scheduleTimes.count {
                let precedingItem = scheduleTimes[i-1]
                let nextItem = scheduleTimes[i]
                if (precedingItem.time <= date && date < nextItem.time) { // If date is between two times...
                    return precedingItem.time
                }
            }
        }
        
        //If the date is after the schedule ends...
        // Return nil if the time is after the schedule is finished.
        return nil
    }
    
    private func getComplicationTemplateForDate(_ complication: CLKComplication, date: Date) -> CLKComplicationTemplate? {
        var bell: String
        var time: Date
        
        let timeAndBell = getTimeAndBellForDate(date)
        
        if timeAndBell != nil {
            if (complication.family == .modularSmall) {
                (bell, time) = timeAndBell!
                let template = CLKComplicationTemplateModularSmallStackText()
                let bellProvider = CLKSimpleTextProvider(text: bell)
                let timeProvider = CLKTimeTextProvider(date: time)
                template.line1TextProvider = bellProvider
                template.highlightLine2 =  false //Highlight line 1.
                template.line2TextProvider = timeProvider
                
                return template
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func getTimeAndBellForDate(_ date: Date) -> (bell: String, time: Date)? {
        if scheduleTimes.count > 0 {
            if date < scheduleTimes.first!.time {
                return (scheduleTimes.first!.blockName, scheduleTimes.first!.time)
            }
            for i in 1..<scheduleTimes.count {
                let precedingItem = scheduleTimes[i-1]
                let nextItem = scheduleTimes[i]
                if (precedingItem.time <= date && date < nextItem.time) { // If date is between two times...
                    return (nextItem.blockName, nextItem.time)
                }
            }
        }
        
        // Return nil if the time is after the schedule is finished.
        return nil
    }
    
    // MARK: - Update Scheduling
    
    func requestedUpdateDidBegin() {
        XScheduleManager.getScheduleForToday( { (schedule: Schedule) in
            if (schedule.date != self.schedule.date) {
                self.schedule = schedule
                if let complications = CLKComplicationServer.sharedInstance().activeComplications {
                    for complication in complications {
                        CLKComplicationServer.sharedInstance().reloadTimeline(for: complication)
                    }
                }
            }
        })
    }
    
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        // Update content every 8 hours.
        handler(Date().addingTimeInterval(8*60*60))
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
    
}
