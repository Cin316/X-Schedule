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
        var task: NSURLSessionTask?
        
        if (CacheManager.scheduleExistsForDate(date)) {
            getCachedScheduleForDate(date, completionHandler: completionHandler)
        } else {
            task = downloadScheduleForDate(date, completionHandler: completionHandler, errorHandler: errorHandler)
        }
        
        return task
    }
    private class func getCachedScheduleForDate(date: NSDate, completionHandler: Schedule -> Void) {
        var schedule: Schedule = CacheManager.loadScheduleForDate(date)
        completionHandler(schedule)
    }
    private class func downloadScheduleForDate(date: NSDate, completionHandler: Schedule -> Void, errorHandler: String -> Void) -> NSURLSessionTask {
        var task: NSURLSessionTask
        
        task = XScheduleDownloader.downloadSchedule(date, completionHandler: { (output: String) in
            var schedule: Schedule
            schedule = XScheduleParser.parseForSchedule(output, date: date)
            completionHandler(schedule)
            CacheManager.cacheSchedule(schedule)
        }, errorHandler: errorHandler)
        
        return task
    }
}