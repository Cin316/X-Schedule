//
//  ScheduleDownloader.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 4/26/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

open class ScheduleDownloader {

    open class func downloadSchedule(_ date: Date, completionHandler: @escaping (String) -> Void, errorHandler: @escaping (String) -> Void) -> URLSessionTask {
        return  URLSessionTask()
    }
    open class func downloadSchedule(_ completionHandler: @escaping (String) -> Void, errorHandler: @escaping (String) -> Void) -> URLSessionTask {
        return downloadSchedule(Date(), completionHandler: completionHandler, errorHandler: errorHandler)
    }
    
    open class func downloadSchedule(_ date: Date, completionHandler: @escaping (String) -> Void) -> URLSessionTask {
        return downloadSchedule(date, completionHandler: completionHandler, errorHandler: { (output: String) in })
    }
}
