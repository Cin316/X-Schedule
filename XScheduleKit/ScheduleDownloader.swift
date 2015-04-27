//
//  ScheduleDownloader.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 4/26/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

public class ScheduleDownloader {

    public class func downloadSchedule(date: NSDate, completionHandler: String -> Void, errorHandler: String -> Void) -> NSURLSessionTask {
        return  NSURLSessionTask()
    }
    public class func downloadSchedule(completionHandler: String -> Void, errorHandler: String -> Void) -> NSURLSessionTask {
        var currentDate = NSDate()
        return downloadSchedule(currentDate, completionHandler: completionHandler, errorHandler: errorHandler)
    }
    
    public class func downloadSchedule(date: NSDate, completionHandler: String -> Void) -> NSURLSessionTask {
        return downloadSchedule(date, completionHandler: completionHandler, errorHandler: { (output: String) in })
    }
}