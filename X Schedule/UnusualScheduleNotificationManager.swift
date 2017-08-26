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
    
    static let notifiedDatesKey = "notifiedDates"
    
    private static let usualSchedules: [String] = [
        "",
        "A Day",
        "G Day",
        "E Day",
        "C Day",
        "X Day",
        "Y Day"
    ]
    
    private static var scheduleTitles: [String] = []
    class func loadScheduleTitles() {
        // Initialize scheduleTitles to an empty array.
        scheduleTitles = []
        
        // Load the past month and the next month of schedules.
        let days = CacheManager.defaultCacheLengthInDays
        for i in -days...days {
            let date: Date = dateDaysFromNow(numOfDays: i)
            XScheduleManager.getScheduleForDate(date, completionHandler: { (schedule: Schedule) in
                scheduleTitles.append(schedule.title)
            }, errorHandler: { (errorText: String) in
                
            }, method: .cache)
        }
    }
    private class func dateDaysFromNow(numOfDays days: Int) -> Date {
        return Date().addingTimeInterval(Double(days*24*60*60))
    }
    
    // Note: I do not use UserNotifications methods because they are not backwards-compatible with older versions of iOS
    class func requestAuthorizationForNotifications() {
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert], categories: nil))
    }
    class func setUpBackgroundFetch() {
        UIApplication.shared.setMinimumBackgroundFetchInterval(60*30) // Minimum fetch interval: 30 minutes.  This method must be called for background fetch to work.
    }
    
    class func backgroundAppRefresh(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if (getEnabled()) {
            fetchAppropriateSchedule(completionHandler)
        }
    }
    private class func fetchAppropriateSchedule(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
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
                sendNotificationIfUnique(dayWord: dayWord, scheduleTitle: schedule.title, date: schedule.date)
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
        for title in scheduleTitles {
            if title == schedule.title {
                occurances += 1
            }
        }
        
        return occurances < 3
    }
    private class func hasManualTrigger(schedule: Schedule) -> Bool {
        return schedule.manuallyMarkedUnusual
    }
    
    // Only sends a notification if a notification for that date hasn't been sent before.
    private class func sendNotificationIfUnique(dayWord: String, scheduleTitle: String, date: Date) {
        if !notificationHasBeenSentForDate(date) {
            sendNotification(dayWord: dayWord, scheduleTitle: scheduleTitle)
            recordNotificationSentInCache(date: date)
        }
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
    
    private class func notificationHasBeenSentForDate(_ date: Date) -> Bool {
        let notifiedDates = getNotifiedDates()
        let dateString = dateToISOString(date)
        
        return notifiedDates.contains(dateString)
    }
    private class func getNotifiedDates() -> [String] {
        let defaults = UserDefaults.init(suiteName: "group.com.cin316.X-Schedule")!
        let notifiedDates = defaults.object(forKey: notifiedDatesKey) as AnyObject?
        
        var output: [String] = [] // If notifiedDates can't be loaded from UserDefaults, output is by default empty
        if let dates = notifiedDates as? [String] {
            output = dates
        }
        
        return output
    }
    private class func loadDateFromISOString(_ string: String) -> Date {
        return setUpParsingDateFormatter().date(from: string)!
    }
    
    private class func recordNotificationSentInCache(date: Date) {
        let defaults = UserDefaults.init(suiteName: "group.com.cin316.X-Schedule")!
        var notifiedDates = getNotifiedDates()
        notifiedDates.append(dateToISOString(date))
        defaults.set(notifiedDates, forKey: notifiedDatesKey)
    }
    private class func storeNotifiedDates(_ notifiedDates: [String]) {
        let defaults = UserDefaults.init(suiteName: "group.com.cin316.X-Schedule")!
        defaults.set(notifiedDates, forKey: notifiedDatesKey)
    }
    private class func dateToISOString(_ date: Date) -> String {
        return setUpParsingDateFormatter().string(from: date)
    }
    
    private class func setUpParsingDateFormatter() -> DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return dateFormatter
    }
    
    // Enable switch methods.
    
    static let notificationSwitchKey: String = "unusualNotificationsEnabled"
    
    open class func setEnabled(_ bool: Bool) {
        let defaults = UserDefaults.init(suiteName: "group.com.cin316.X-Schedule")!
        defaults.set(bool, forKey: notificationSwitchKey)
    }
    open class func getEnabled() -> Bool {
        setDefaultNotificationsSetting()
        let defaults = UserDefaults.init(suiteName: "group.com.cin316.X-Schedule")!
        let object: Bool = defaults.bool(forKey: notificationSwitchKey)
        
        return object
    }
    private class func setDefaultNotificationsSetting() {
        if (!notificationsSettingExists()) {
            setEnabled(true)
        }
    }
    private class func notificationsSettingExists() -> Bool {
        let defaults = UserDefaults.init(suiteName: "group.com.cin316.X-Schedule")!
        if (defaults.object(forKey: notificationSwitchKey) == nil) {
            return false
        } else {
            return true
        }
    }
    
    
}
