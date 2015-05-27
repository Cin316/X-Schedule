//
//  ScheduleManager.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 5/27/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

public class ScheduleManager {
    public class func getScheduleForDate(date: NSDate, completionHandler: Schedule -> Void, errorHandler: String -> Void) -> NSURLSessionTask? {
        return nil
    }
    public class func getScheduleForDate(date: NSDate, completionHandler: Schedule -> Void) -> NSURLSessionTask? {
        return getScheduleForDate(date, completionHandler: completionHandler, errorHandler: { (output: String) in })
    }
    public class func getScheduleForToday(completionHandler: Schedule -> Void, errorHandler: String -> Void) -> NSURLSessionTask? {
        return getScheduleForDate(NSDate(), completionHandler: completionHandler, errorHandler: errorHandler)
    }
    public class func getScheduleForToday(completionHandler: Schedule -> Void) -> NSURLSessionTask? {
        return getScheduleForToday(completionHandler, errorHandler: { (output: String) in })
    }
}