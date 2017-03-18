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
}

open class ScheduleManager {
    @discardableResult
    open class func getScheduleForDate(_ date: Date, completionHandler: @escaping (Schedule) -> Void, errorHandler: @escaping (String) -> Void, method: inout DownloadMethod) -> URLSessionTask? {
        return nil
    }
    @discardableResult
    open class func getScheduleForDate(_ date: Date, completionHandler: @escaping (Schedule) -> Void, errorHandler: @escaping (String) -> Void) -> URLSessionTask? {
        var unusedEnum: DownloadMethod = DownloadMethod.download //Value doesn't matter, just provides a blank, unused DownloadMethod.
        return getScheduleForDate(date, completionHandler: completionHandler, errorHandler: errorHandler, method: &unusedEnum)
    }
    @discardableResult
    open class func getScheduleForDate(_ date: Date, completionHandler: @escaping (Schedule) -> Void) -> URLSessionTask? {
        return getScheduleForDate(date, completionHandler: completionHandler, errorHandler: { (output: String) in })
    }
    @discardableResult
    open class func getScheduleForToday(_ completionHandler: @escaping (Schedule) -> Void, errorHandler: @escaping (String) -> Void) -> URLSessionTask? {
        return getScheduleForDate(Date(), completionHandler: completionHandler, errorHandler: errorHandler)
    }
    @discardableResult
    open class func getScheduleForToday(_ completionHandler: @escaping (Schedule) -> Void) -> URLSessionTask? {
        return getScheduleForToday(completionHandler, errorHandler: { (output: String) in })
    }
}
