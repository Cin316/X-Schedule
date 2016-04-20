//
//  CacheManager.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 5/30/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

public class CacheManager {
    
    public static let defaultCacheLengthInDays = 30
    public static let scheduleCacheDirectoryName = "Schedules"
    
    public class func scheduleExistsForDate(date: NSDate) -> Bool {
        let path: String = pathForDate(date)
        let exists: Bool = fileManager().fileExistsAtPath(path)
        
        return exists
    }
    public class func loadScheduleForDate(date: NSDate) -> Schedule? {
        var schedule: Schedule?
        let path: String = pathForDate(date)
        let contents: String? = try? String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
        if let realContents = contents {
            schedule = XScheduleParser.parseForSchedule(realContents, date: date)
        } else {
            schedule = nil
        }
        return schedule
    }
    public class func cacheSchedule(schedule: Schedule) {
        createScheduleCacheDir()
        let path: String = pathForDate(schedule.date)
        let contents: String = XScheduleParser.storeScheduleInString(schedule)
        
        do {
            try contents.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
        } catch _ {
        }
    }
    
    public class func clearCache() {
        var files: [AnyObject]?
        files = try! fileManager().contentsOfDirectoryAtPath(scheduleCacheDirectory())
        
        if let paths = files as? [String] {
            for file in paths {
                let cacheURL: NSURL = NSURL(fileURLWithPath: scheduleCacheDirectory())
                let path: String = cacheURL.URLByAppendingPathComponent(file).relativePath!
                try! fileManager().removeItemAtPath(path)

            }
        }
    }
    
    public class func buildCache() {
        buildCacheForLengthOfTime(numOfDays: defaultCacheLengthInDays)
    }
    public class func buildCacheForLengthOfTime(numOfDays days: Int) {
        for i in -days...days {
            let date: NSDate = dateDaysFromNow(numOfDays: i)
            XScheduleManager.downloadScheduleForDate(date, completionHandler: { (schedule: Schedule) in}, errorHandler: { (errorText: String) in})
        }
    }
    private class func dateDaysFromNow(numOfDays days: Int) -> NSDate {
        var date: NSDate
        date = NSDate().dateByAddingTimeInterval(Double(days*24*60*60))
        
        return date
    }
    
    private class func fileManager() -> NSFileManager {
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        
        return fileManager
    }
    private class func documentsDirectory() -> String {
        let directories: [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) 
        let documentsDirectory: String =  directories[0]
        
        return documentsDirectory
    }
    private class func scheduleCacheDirectory() -> String {
        let documentsURL: NSURL = NSURL(fileURLWithPath: documentsDirectory())
        let path: String = documentsURL.URLByAppendingPathComponent(scheduleCacheDirectoryName).relativePath!
        
        return path
    }
    private class func createScheduleCacheDir() {
        if ( !fileManager().fileExistsAtPath(scheduleCacheDirectory()) ) {
            do {
                try fileManager().createDirectoryAtPath(scheduleCacheDirectory(), withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }
    }
    
    private class func pathForDate(date: NSDate) -> String {
        let cacheDirectoryURL: NSURL = NSURL(fileURLWithPath: scheduleCacheDirectory())
        let scheduleFileName: String = fileNameForDate(date)
        let path: String = cacheDirectoryURL.URLByAppendingPathComponent(scheduleFileName).relativePath!
        
        return path
    }
    
    private class func fileNameForDate(date: NSDate) -> String {
        let dateFormat: NSDateFormatter = setUpFileDateFormatter()
        let dateString:  String = dateFormat.stringFromDate(date)
        let filename = "\(dateString).xml"
        
        return filename
    }
    private class func setUpFileDateFormatter() -> NSDateFormatter {
        let dateFormat: NSDateFormatter = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        dateFormat.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        return dateFormat
    }
}
