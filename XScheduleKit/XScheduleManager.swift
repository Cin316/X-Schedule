//
//  XScheduleManager.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 5/27/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

open class XScheduleManager: ScheduleManager {
    @discardableResult
    open override class func getScheduleForDate(_ date: Date, completionHandler: @escaping (Schedule) -> Void, errorHandler: @escaping (String) -> Void, method: inout DownloadMethod) -> URLSessionTask? {
        var task: URLSessionTask?
        
        if (CacheManager.scheduleExistsForDate(date)) {
            getCachedScheduleForDate(date, completionHandler: completionHandler, errorHandler: errorHandler)
            method = DownloadMethod.cache
        } else {
            task = downloadScheduleForDate(date, completionHandler: completionHandler, errorHandler: errorHandler)
            method = DownloadMethod.download
        }
        
        return task
    }
    private class func getCachedScheduleForDate(_ date: Date, completionHandler: @escaping (Schedule) -> Void, errorHandler: @escaping (String) -> Void) {
        let schedule: Schedule? = CacheManager.loadScheduleForDate(date)
        if (schedule != nil) {
            completionHandler(substituteSchedule(schedule!))
        } else {
            errorHandler("Error loading schedule from cache.")
        }
    }
    @discardableResult
    internal class func downloadScheduleForDate(_ date: Date, completionHandler: @escaping (Schedule) -> Void, errorHandler: @escaping (String) -> Void) -> URLSessionTask {
        var task: URLSessionTask
        
        task = XScheduleDownloader.downloadSchedule(date, completionHandler: { (output: String) in
            var schedule: Schedule
            schedule = XScheduleParser.parseForSchedule(output, date: date)
            CacheManager.cacheSchedule(schedule)
            completionHandler(self.substituteSchedule(schedule))
        }, errorHandler: errorHandler)
        
        return task
    }
    private class func substituteSchedule(_ schedule: Schedule) -> Schedule {
        var displaySchedule: Schedule
        displaySchedule = SubstitutionManager.substituteItemsInScheduleIfEnabled(schedule, substitutions: SubstitutionManager.loadSubstitutions())
        
        return  displaySchedule
    }
}
