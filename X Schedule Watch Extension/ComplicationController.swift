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
    
    var schedule: Schedule!
    
    override init() {
        super.init()
        XScheduleManager.getScheduleForToday( { (schedule: Schedule) in
            self.schedule = schedule
        })
    }
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.Forward, .Backward])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        if (schedule.items.count > 0) {
            handler(schedule.items.first?.startTime)
        } else {
            handler(nil)
        }
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        if (schedule.items.count > 0) {
            handler(schedule.items.last?.endTime)
        } else {
            handler(nil)
        }
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    // TODO Support ALL the edge cases.
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        // Call the handler with the current timeline entry
        handler(getTimelineEntryForDate(complication, date: NSDate()))
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        var templates: [CLKComplicationTimelineEntry] = []
        let array = scheduleToArray(schedule)
        var index: Int = array.count;
        
        //Find first item.
        for _ in array {
            if (date.compare(array[index].time) == .OrderedDescending) {
                break;
            }
            index -= 1
        }
        
        while templates.count <= limit && index >= 0 {
            templates.append(getTimelineEntryForDate(complication, date: array[index].time)!)
            index -= 1
        }
        
        handler(templates)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        var templates: [CLKComplicationTimelineEntry] = []
        let array = scheduleToArray(schedule)
        var index: Int = 0;
        
        //Find first item.
        for item in array {
            if (date.compare(item.time) == .OrderedAscending) {
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
    
    private func scheduleToArray(schedule: Schedule) -> [(blockName: String, time: NSDate)] {
        var array: [(blockName: String, time: NSDate)] = []
        for item in schedule.items {
            array.append((blockName: item.blockName, time: item.startTime!))
            array.append((blockName: item.blockName, time: item.endTime!))
        }
        
        return array
    }
    
    
    private func getTimelineEntryForDate(complication: CLKComplication, date: NSDate) -> CLKComplicationTimelineEntry? {
        let template = getComplicationTemplateForDate(complication, date: date)
        let timelineEntry = CLKComplicationTimelineEntry(date: getStartTimeForTime(date), complicationTemplate: template!)
        
        return timelineEntry
    }
    private func getStartTimeForTime(date: NSDate) -> NSDate {
        for item in schedule.items {
            if (date.compare(item.startTime!) == .OrderedAscending || date.compare(item.startTime!) == .OrderedSame) {
                return item.startTime!
            } else if (date.compare(item.endTime!) == .OrderedAscending || date.compare(item.endTime!) == .OrderedSame) {
                return item.endTime!
            }
        }
        //If the date is after the schedule ends...
        return date
    }
    
    private func getComplicationTemplateForDate(complication: CLKComplication, date: NSDate) -> CLKComplicationTemplate? {
        var bell: String
        var time: NSDate
        
        (bell, time) = getTimeAndBellForDate(date)
        
        if (complication.family == .ModularSmall) {
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
    }
    
    private func getTimeAndBellForDate(date: NSDate) -> (bell: String, time: NSDate) {
        var bell: String?
        var time: NSDate?
        
        for item in schedule.items {
            if (date.compare(item.startTime!) == .OrderedAscending || date.compare(item.startTime!) == .OrderedSame) {
                bell = item.blockName
                time = item.startTime!
            } else if (date.compare(item.endTime!) == .OrderedAscending || date.compare(item.endTime!) == .OrderedSame) {
                bell = item.blockName
                time = item.endTime!
            }
        }
        
        return (bell!, time!)
    }
    
    // MARK: - Update Scheduling
    
    func requestedUpdateDidBegin() {
        XScheduleManager.getScheduleForToday( { (schedule: Schedule) in
            if (schedule.date != self.schedule.date) {
                self.schedule = schedule
                if let complications = CLKComplicationServer.sharedInstance().activeComplications {
                    for complication in complications {
                        CLKComplicationServer.sharedInstance().reloadTimelineForComplication(complication)
                    }
                }
            }
        })
    }
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        // Update content every 8 hours.
        handler(NSDate().dateByAddingTimeInterval(8*60*60))
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
    
}
