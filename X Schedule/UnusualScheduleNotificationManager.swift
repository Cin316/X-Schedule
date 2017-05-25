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
    
    // Note: I do not use UserNotifications methods because they are not backwards-compatible with older versions of iOS
    class func requestAuthorizationForNotifications() {
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert], categories: nil))
        UIApplication.shared.setMinimumBackgroundFetchInterval(60*30) // Minimum fetch interval: 30 minutes.  This method must be called for background fetch to work
    }
    
    // TODO Prevent sending repeated notifications.
    
    class func backgroundAppRefresh(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if (currentHour() < 14) { // 12AM-10AM: Look for today's schedule.
            lookForUnusualSchedule(onDate: Date(), dayWord: "Today", completionHandler: completionHandler)
        } else if (14 <= currentHour() && currentHour() < 17) { // 10AM-5PM: Don't look for unusual schedules.
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
        return isRare(schedule: schedule) || hasManualTrigger(schedule: schedule)
    }
    private class func isRare(schedule: Schedule) -> Bool {
        return true // TODO Implement rare detection
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
