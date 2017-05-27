//
//  UnusualScheduleNotificationManager.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 5/24/17.
//  Copyright © 2017 Nicholas Reichert.
//

import UIKit
import XScheduleKit

class UnusualScheduleNotificationManager {
    
    private static let usualSchedules: [String] = [
        "",
        "A Day",
        "G Day",
        "E Day",
        "C Day",
        "X Day",
        "Y Day"
    ]
    
    private static var scheduleTitles: [String]?
    private static var scheduleTitlesLoaded = 0
    class func getScheduleTitles() -> [String] {
        // Use a singleton-like pattern for scheduleTitles.  scheduleTitles is nil until it's accessed, then create one shared instance.
        if let titles = scheduleTitles {
            return titles
        } else {
            // Initialize scheduleTitles to an empty array.
            scheduleTitles = []
            
            // Load the past month and the next month of schedules.
            let days = CacheManager.defaultCacheLengthInDays
            for i in -days...days {
                let date: Date = dateDaysFromNow(numOfDays: i)
                XScheduleManager.getScheduleForDate(date, completionHandler: { (schedule: Schedule) in
                    scheduleTitles?.append(schedule.title)
                    scheduleTitlesLoaded += 1
                }, errorHandler: { (errorText: String) in
                    scheduleTitlesLoaded += 1
                }, method: .cache)
            }
            
            // Wait for schedules to finish loading.
            while scheduleTitlesLoaded<=days*2 {
                // The code inside this while loop does not usually get called, because loading from the cache is so fast.
                usleep(10_000) // Sleep for 0.01 seconds (10,000 millionths of a second)
            }
            
            return scheduleTitles!
        }
    }
    private class func dateDaysFromNow(numOfDays days: Int) -> Date {
        return Date().addingTimeInterval(Double(days*24*60*60))
    }
    
    // Note: I do not use UserNotifications methods because they are not backwards-compatible with older versions of iOS
    class func requestAuthorizationForNotifications() {
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert], categories: nil))
        UIApplication.shared.setMinimumBackgroundFetchInterval(60*15/*60*30*/) // Minimum fetch interval: 30 minutes.  This method must be called for background fetch to work
    }
    
    // TODO Prevent sending repeated notifications.
    
    class func backgroundAppRefresh(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if (currentHour() < 10) { // 12AM-10AM: Look for today's schedule.
            lookForUnusualSchedule(onDate: Date(), dayWord: "Today", completionHandler: completionHandler)
        } else if (10 <= currentHour() && currentHour() < 17) { // 10AM-5PM: Don't look for unusual schedules.
            completionHandler(.noData)
        } else { // 17 <= currentHour // 5PM-12PM: Look for tomorrow's schedule.
            lookForUnusualSchedule(onDate: Date().addingTimeInterval(60*60*24), dayWord: "Tomorrow", completionHandler: completionHandler)
        }
    }
    private class func currentHour() -> Int {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH" // Hours, 00-23
        let hours = Int(formatter.string(from: today))!
        
        return hours
    }
    
    private class func lookForUnusualSchedule(onDate date: Date, dayWord: String, completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        XScheduleManager.getScheduleForDate(date, completionHandler: { (schedule: Schedule) in
            if (isUnusual(schedule: schedule)) {
                sendNotification(dayWord: dayWord, scheduleTitle: schedule.title)
            }
            completionHandler(.newData)
        }, errorHandler: { (string: String) in
            completionHandler(.failed)
        }, method: .download)
    }
    private class func isUnusual(schedule: Schedule) -> Bool {
        return (!usualSchedules.contains(schedule.title) && isRare(schedule: schedule)) || hasManualTrigger(schedule: schedule)
    }
    private class func isRare(schedule: Schedule) -> Bool {
        var occurances = 0
        for title in getScheduleTitles() {
            if title == schedule.title {
                occurances += 1
            }
        }
        
        return occurances < 3
    }
    private class func hasManualTrigger(schedule: Schedule) -> Bool {
        return false // TODO Implement manual trigger support
    }
    
    private class func sendNotification(dayWord: String, scheduleTitle: String) {
        let notification = UILocalNotification()
        notification.alertBody = "\(dayWord)'s schedule is: \(scheduleTitle)."
        if #available(iOS 8.2, *) {
            notification.alertTitle = "Unusual Schedule"
        } else {
            notification.alertBody = "Unusual Schedule\n" + (notification.alertBody ?? "")
        }
        notification.fireDate = Date()
        
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
}
