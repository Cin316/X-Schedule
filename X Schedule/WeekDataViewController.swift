//
//  WeekDataViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 4/4/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit
import XScheduleKit

class WeekDataViewController: ScheduleViewController {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var finishedLoadingNum: Int = 0
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var titleLabel1: UILabel!
    @IBOutlet weak var emptyLabel1: UILabel!
    
    @IBOutlet weak var titleLabel2: UILabel!
    @IBOutlet weak var emptyLabel2: UILabel!
    
    @IBOutlet weak var titleLabel3: UILabel!
    @IBOutlet weak var emptyLabel3: UILabel!
    
    @IBOutlet weak var titleLabel4: UILabel!
    @IBOutlet weak var emptyLabel4: UILabel!
    
    @IBOutlet weak var titleLabel5: UILabel!
    @IBOutlet weak var emptyLabel5: UILabel!
    
    private let daysPerView: Int = 7
    override func numberOfDaysPerView() -> Int {
        return daysPerView
    }
    
    var scheduleMonday: NSDate {
        get {
            var calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            var weekday: Int = calendar.component(.CalendarUnitWeekday, fromDate: scheduleDate)
            var daysPastMonday: Int = weekday-2
            var seconds: Double = Double(-24*60*60*daysPastMonday)
            return scheduleDate.dateByAddingTimeInterval(seconds)
        }
    }
    
    var tasks: [NSURLSessionTask] = []
    var downloadMethods: [DownloadMethod] = [DownloadMethod](count: 5, repeatedValue: DownloadMethod.Cache)
    var downloadCount: Int {
        get {
            var num: Int = 0
            for method in downloadMethods {
                if (method == DownloadMethod.Download) {
                    num++
                }
            }
            return num
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshSchedule()
    }
    
    override func refreshSchedule() {
        cancelRequests()
        refreshSchedules()
        startTaskCounter()
        clearWeek()
        displayDateLabel()
    }
    private func clearWeek() {
        clearScheduleTables()
    }
    private func clearScheduleTables() {
        //Blank out every schedule.
        var blankSchedule: Schedule = Schedule()
        for (var i=0; i<5; i++) {
            if let tableController = self.childViewControllers[i] as? ScheduleTableController {
                if (downloadMethods[i] == DownloadMethod.Download) {
                    tableController.schedule = blankSchedule
                }
            }
        }
    }
    private func clearEmptyLabels() {
        //Clear all "No classes" labels.
        for (var i=1; i<=5; i++) {
            emptyLabel(i).text = ""
        }
    }
    private func refreshSchedules() {
        //Refresh schedule for each day of the week.
        for (var i=1; i<=5; i++) {
            refreshScheduleNum(i)
        }
    }
    
    private func displayDateLabel() {
        dateLabel.text = dateLabelText()
    }
    private func dateLabelText() -> String {
        //Display correctly formatted date label.
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        
        var mondayText: String = dateFormatter.stringFromDate(self.scheduleMonday)
        var fridayText: String = dateFormatter.stringFromDate(self.scheduleMonday.dateByAddingTimeInterval(60*60*24*4))
        
        var year: Int = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitYear, fromDate: self.scheduleMonday)
        
        return "\(mondayText) - \(fridayText), \(year)"
    }
    
    private func refreshScheduleNum(num: Int) {
        var method: DownloadMethod = DownloadMethod.Download
        
        // Download today's schedule from the St. X website.
        var newTask: NSURLSessionTask? = XScheduleManager.getScheduleForDate(downloadDateForNum(num),
            completionHandler: { (schedule: Schedule) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.handleCompletionOfDownload(schedule, num: num)
                }
            },
            errorHandler: { (errorText: String) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.handleError(errorText, num: num)
                }
            }, method: &method
        )
        
        downloadMethods[num-1] = method
        
        if (newTask != nil) {
            tasks.append(newTask!)
        }
    }
    private func handleCompletionOfDownload(schedule: Schedule, num: Int) {
        displayScheduleInTable(schedule, num: num)
        displayTitleForSchedule(schedule, titleLabel: titleLabel(num))
        displayEmptyLabelForSchedule(schedule, emptyLabel: emptyLabel(num))
        markOneTaskAsFinished()
    }
    private func displayScheduleInTable(schedule: Schedule, num: Int) {
        if let tableController = childViewControllers[num-1] as? ScheduleTableController {
            tableController.displaySchedule(schedule)
        }
    }
    private func displayTitleForSchedule(schedule: Schedule, titleLabel: UILabel) {
        //Display normal title.
        titleLabel.text = schedule.title
        
        //Add default weekend title if needed.
        if (NSCalendar.currentCalendar().isDateInWeekend(scheduleMonday)) {
            titleLabel.text = "Weekend"
        }
    }
    private func displayEmptyLabelForSchedule(schedule: Schedule, emptyLabel: UILabel) {
        if (schedule.items.isEmpty) {
            emptyLabel.text = "No classes"
        } else {
            emptyLabel.text = ""
        }
    }
    
    private func titleLabel(num: Int) -> UILabel {
        var titleLabel: UILabel!
        switch num {
        case 1:
            titleLabel = self.titleLabel1
        case 2:
            titleLabel = self.titleLabel2
        case 3:
            titleLabel = self.titleLabel3
        case 4:
            titleLabel = self.titleLabel4
        case 5:
            titleLabel = self.titleLabel5
        default:
            return UILabel()
        }
        
        return titleLabel
    }
    private func emptyLabel(num: Int) -> UILabel {
        var emptyLabel: UILabel!
        switch num {
        case 1:
            emptyLabel = self.emptyLabel1
        case 2:
            emptyLabel = self.emptyLabel2
        case 3:
            emptyLabel = self.emptyLabel3
        case 4:
            emptyLabel = self.emptyLabel4
        case 5:
            emptyLabel = self.emptyLabel5
        default:
            return UILabel()
        }
        
        return emptyLabel
    }
    private func downloadDateForNum(num: Int) -> NSDate {
        var downloadDate: NSDate = scheduleMonday.dateByAddingTimeInterval(Double(24*60*60*(num-1)))
        
        return downloadDate
    }
    
    private func startTaskCounter() {
        //Start loading indicator before download.
        if (!(downloadCount==0)) {
            startLoading()
        }
        finishedLoadingNum = 0
    }
    private func markOneTaskAsFinished() {
        //Stop loading indicator after everything is complete.
        finishedLoadingNum++
        if(finishedLoadingNum>=downloadCount) {
            finishedLoadingNum = 0
            stopLoading()
            
            clearTasks()
        }
    }
    private func clearTasks() {
        //Clear references to tasks from tasks variable.
        tasks = []
    }
    private func cancelRequests() {
        for task in tasks {
            task.cancel()
        }
        clearTasks()
    }
    
    private func handleError(errorText: String, num: Int) {
        displayAlertWithText(errorText)
        markOneTaskAsFinished()
    }
    
    private func startLoading() {
        loadingIndicator.startAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    private func stopLoading() {
        loadingIndicator.stopAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
}
