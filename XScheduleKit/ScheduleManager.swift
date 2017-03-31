//
//  ScheduleManager.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 5/27/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

public enum DownloadMethod {
    case download
    case cache
    case auto
}

open class ScheduleManager {
    @discardableResult
    open class func getScheduleForDate(_ date: Date, completionHandler: @escaping (Schedule) -> Void, errorHandler: @escaping (String) -> Void, method: DownloadMethod) -> (DownloadMethod, URLSessionTask?) {
        return (method, nil)
    }
    @discardableResult
    open class func getScheduleForDate(_ date: Date, completionHandler: @escaping (Schedule) -> Void, errorHandler: @escaping (String) -> Void) -> (DownloadMethod, URLSessionTask?) {
        return getScheduleForDate(date, completionHandler: completionHandler, errorHandler: errorHandler, method: DownloadMethod.auto)
    }
    @discardableResult
    open class func getScheduleForDate(_ date: Date, completionHandler: @escaping (Schedule) -> Void) -> (DownloadMethod, URLSessionTask?) {
        return getScheduleForDate(date, completionHandler: completionHandler, errorHandler: { (output: String) in })
    }
    @discardableResult
    open class func getScheduleForToday(_ completionHandler: @escaping (Schedule) -> Void, errorHandler: @escaping (String) -> Void) -> (DownloadMethod, URLSessionTask?) {
        return getScheduleForDate(Date(), completionHandler: completionHandler, errorHandler: errorHandler)
    }
    @discardableResult
    open class func getScheduleForToday(_ completionHandler: @escaping (Schedule) -> Void) -> (DownloadMethod, URLSessionTask?) {
        return getScheduleForToday(completionHandler, errorHandler: { (output: String) in })
    }
}
