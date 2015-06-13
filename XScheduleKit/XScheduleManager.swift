//
//  XScheduleManager.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 5/27/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

public class XScheduleManager: ScheduleManager {
    public override class func getScheduleForDate(date: NSDate, completionHandler: Schedule -> Void, errorHandler: String -> Void, inout method: DownloadMethod) -> NSURLSessionTask? {
        var task: NSURLSessionTask?
        
        if (CacheManager.scheduleExistsForDate(date)) {
            getCachedScheduleForDate(date, completionHandler: completionHandler, errorHandler: errorHandler)
            method = DownloadMethod.Cache
        } else {
            task = downloadScheduleForDate(date, completionHandler: completionHandler, errorHandler: errorHandler)
            method = DownloadMethod.Download
        }
        
        return task
    }
    private class func getCachedScheduleForDate(date: NSDate, completionHandler: Schedule -> Void, errorHandler: String -> Void) {
        var schedule: Schedule? = CacheManager.loadScheduleForDate(date)
        if (schedule != nil) {
            completionHandler(schedule!)
        } else {
            errorHandler("Error loading schedule from cache.")
        }
    }
    internal class func downloadScheduleForDate(date: NSDate, completionHandler: Schedule -> Void, errorHandler: String -> Void) -> NSURLSessionTask {
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
