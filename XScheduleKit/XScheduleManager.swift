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
    open override class func getScheduleForDate(_ date: Date, completionHandler: @escaping (Schedule) -> Void, errorHandler: @escaping (String) -> Void, method: DownloadMethod) -> (DownloadMethod, URLSessionTask?) {
        var task: URLSessionTask?
        let methodUsed: DownloadMethod = determineDownloadMethod(date: date, specifiedMethod: method)
        NSLog("[XScheduleManager] Determining download method. Requested: \(method) Decided on: \(methodUsed)")
        
        if (methodUsed == .cache) {
            NSLog("[XScheduleManager] Getting Schedule for date \(date) using CACHE method.")
            getCachedScheduleForDate(date, completionHandler: completionHandler, errorHandler: errorHandler)
        } else { // (methodUsed == .download)
            NSLog("[XScheduleManager] Getting Schedule for date \(date) using DOWNLOAD method.")
            task = downloadScheduleForDate(date, completionHandler: completionHandler, errorHandler: errorHandler)
        }
        
        return (methodUsed, task)
    }
    // Note: It may be worth adding a check to scheduleExistsForDate here if specifiedMethod == .cache .
    private class func determineDownloadMethod(date: Date, specifiedMethod: DownloadMethod) -> DownloadMethod {
        if (specifiedMethod == .auto) {
            if (CacheManager.scheduleExistsForDate(date)) {
                return .cache
            } else {
                return .download
            }
        } else {
            return specifiedMethod
        }
    }
    private class func getCachedScheduleForDate(_ date: Date, completionHandler: @escaping (Schedule) -> Void, errorHandler: @escaping (String) -> Void) {
        let schedule: Schedule? = CacheManager.loadScheduleForDate(date)
        if (schedule != nil) {
            completionHandler(substituteSchedule(schedule!))
        } else {
            errorHandler("Error loading schedule from cache.")
        }
    }
    private class func downloadScheduleForDate(_ date: Date, completionHandler: @escaping (Schedule) -> Void, errorHandler: @escaping (String) -> Void) -> URLSessionTask {
        var task: URLSessionTask
        
        task = XScheduleDownloader.downloadSchedule(date, completionHandler: { (output: String) in
            var schedule: Schedule
            schedule = XScheduleParser.parseForSchedule(output, date: date)
            schedule = getBestSchedule(date: date, schedule: schedule)
            CacheManager.cacheSchedule(schedule)
            completionHandler(self.substituteSchedule(schedule))
        }, errorHandler: errorHandler)
        
        return task
    }
    // If we just downloaded a blank schedule, and there's a more full one in the cache, use the one in the cache.
    // This should fix the throttling error overwriting good cached schedules.
    private class func getBestSchedule(date: Date, schedule downloadedSchedule: Schedule) -> Schedule {
        let cachedSchedule = CacheManager.loadScheduleForDate(date)
        let cacheIsBlank: Bool = scheduleIsBlank(schedule: cachedSchedule)
        let downloadIsBlank: Bool = scheduleIsBlank(schedule: downloadedSchedule)
        if (cacheIsBlank) {
            return downloadedSchedule
        } else {
            if (downloadIsBlank) {
                return cachedSchedule!
            } else {
                return downloadedSchedule
            }
        }
    }
    // A blank schedule here is defined as having an empty items list and a blank title.
    private class func scheduleIsBlank(schedule: Schedule?) -> Bool {
        if (schedule == nil) {
            return true
        } else {
            if (schedule!.items.count == 0 && schedule!.title == "") {
                return true
            } else {
                return false
            }
        }
        
    }
    
    private class func substituteSchedule(_ schedule: Schedule) -> Schedule {
        var displaySchedule: Schedule
        displaySchedule = SubstitutionManager.substituteItemsInScheduleIfEnabled(schedule, substitutions: SubstitutionManager.loadSubstitutions())
        
        return  displaySchedule
    }
}
