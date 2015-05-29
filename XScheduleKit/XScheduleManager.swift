//
//  XScheduleManager.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 5/27/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

public class XScheduleManager: ScheduleManager {
    public override class func getScheduleForDate(date: NSDate, completionHandler: Schedule -> Void, errorHandler: String -> Void) -> NSURLSessionTask? {
        var task: NSURLSessionTask
        task = XScheduleDownloader.downloadSchedule(date, completionHandler: { (output: String) in
            var schedule: Schedule
            schedule = XScheduleParser.parseForSchedule(output, date: date)
            completionHandler(schedule)
        }, errorHandler: errorHandler)
        
        return task
    }
}