//
//  CacheManager.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 5/30/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

open class CacheManager {
    
    open static let defaultCacheLengthInDays = 30
    open static let scheduleCacheDirectoryName = "Schedules"
    
    open class func scheduleExistsForDate(_ date: Date) -> Bool {
        let path: String = pathForDate(date)
        let exists: Bool = fileManager().fileExists(atPath: path)
        
        return exists
    }
    open class func loadScheduleForDate(_ date: Date) -> Schedule? {
        NSLog("[CacheManager] Loading cached schedule for date \(date)")
        var schedule: Schedule?
        let path: String = pathForDate(date)
        let contents: String? = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
        if let realContents = contents {
            schedule = XScheduleParser.parseForSchedule(realContents, date: date)
        } else {
            schedule = nil
        }
        return schedule
    }
    open class func cacheSchedule(_ schedule: Schedule) {
        createScheduleCacheDir()
        let path: String = pathForDate(schedule.date as Date)
        let contents: String = XScheduleParser.storeScheduleInString(schedule)
        
        do {
            try contents.write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
        } catch _ {
        }
    }
    
    open class func clearCache() {
        var files: [AnyObject]?
        files = try! fileManager().contentsOfDirectory(atPath: scheduleCacheDirectory()) as [AnyObject]?
        
        if let paths = files as? [String] {
            for file in paths {
                let cacheURL: URL = URL(fileURLWithPath: scheduleCacheDirectory())
                let path: String = cacheURL.appendingPathComponent(file).relativePath
                try! fileManager().removeItem(atPath: path)

            }
        }
    }
    
    open class func buildCache() {
        NSLog("[CacheManager] Building the cache...")
        buildCacheForLengthOfTime(pastDays: defaultCacheLengthInDays, futureDays: defaultCacheLengthInDays)
    }
    open class func buildCacheForLengthOfTime(pastDays: Int, futureDays: Int) {
        for i in -pastDays...futureDays {
            let date: Date = dateDaysFromNow(numOfDays: i)
            XScheduleManager.getScheduleForDate(date, completionHandler: { (schedule: Schedule) in}, errorHandler: { (errorText: String) in}, method: .download)
        }
    }
    private class func dateDaysFromNow(numOfDays days: Int) -> Date {
        var date: Date
        date = Date().addingTimeInterval(Double(days*24*60*60))
        
        return date
    }
    
    private class func fileManager() -> FileManager {
        let fileManager: FileManager = FileManager.default
        
        return fileManager
    }
    private class func documentsDirectory() -> String {
        let directories: [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true) 
        let documentsDirectory: String =  directories[0]
        
        return documentsDirectory
    }
    private class func scheduleCacheDirectory() -> String {
        let documentsURL: URL = URL(fileURLWithPath: documentsDirectory())
        let path: String = documentsURL.appendingPathComponent(scheduleCacheDirectoryName).relativePath
        
        return path
    }
    private class func createScheduleCacheDir() {
        if ( !fileManager().fileExists(atPath: scheduleCacheDirectory()) ) {
            do {
                try fileManager().createDirectory(atPath: scheduleCacheDirectory(), withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }
    }
    
    private class func pathForDate(_ date: Date) -> String {
        let cacheDirectoryURL: URL = URL(fileURLWithPath: scheduleCacheDirectory())
        let scheduleFileName: String = fileNameForDate(date)
        let path: String = cacheDirectoryURL.appendingPathComponent(scheduleFileName).relativePath
        
        return path
    }
    
    private class func fileNameForDate(_ date: Date) -> String {
        let dateFormat: DateFormatter = setUpFileDateFormatter()
        let dateString:  String = dateFormat.string(from: date)
        let filename = "\(dateString).xml"
        
        return filename
    }
    private class func setUpFileDateFormatter() -> DateFormatter {
        let dateFormat: DateFormatter = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        
        return dateFormat
    }
}
