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
    @IBOutlet weak var blankLabel1: UILabel!
    
    @IBOutlet weak var titleLabel2: UILabel!
    @IBOutlet weak var blankLabel2: UILabel!
    
    @IBOutlet weak var titleLabel3: UILabel!
    @IBOutlet weak var blankLabel3: UILabel!
    
    @IBOutlet weak var titleLabel4: UILabel!
    @IBOutlet weak var blankLabel4: UILabel!
    
    @IBOutlet weak var titleLabel5: UILabel!
    @IBOutlet weak var blankLabel5: UILabel!
    
    var scheduleMonday: NSDate {
        get{
            var calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            var weekday: Int = calendar.component(.CalendarUnitWeekday, fromDate: scheduleDate)
            var daysPastMonday: Int = weekday-2
            var seconds: Double = Double(-24*60*60*daysPastMonday)
            return scheduleDate.dateByAddingTimeInterval(seconds)
        }
    }
    
    var tasks: [NSURLSessionTask] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        refreshSchedule()
    }
    
    override func refreshSchedule() {
        //Start loading indicator before download.
        loadingIndicator.startAnimating()
        finishedLoadingNum = 0
        
        //Blank out every schedule.
        var items: [ScheduleItem] = []
        var blankSchedule: Schedule = Schedule(items: items)
        for (var i=0; i<5; i++) {
            if let tableController = self.childViewControllers[i] as? ScheduleTableController {
                tableController.schedule = blankSchedule
                let tableView = (tableController.view as? UITableView)!
                tableView.reloadData()
            }
        }
        //Clear all "No classes" labels.
        blankLabel1.text = ""
        blankLabel2.text = ""
        blankLabel3.text = ""
        blankLabel4.text = ""
        blankLabel5.text = ""
        
        //Refresh schedule for each day of the week.
        refreshScheduleNum(1)
        refreshScheduleNum(2)
        refreshScheduleNum(3)
        refreshScheduleNum(4)
        refreshScheduleNum(5)
        
        
        //Display correctly formatted date label.
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        var mondayText = dateFormatter.stringFromDate(self.scheduleMonday)
        var fridayText = dateFormatter.stringFromDate(self.scheduleMonday.dateByAddingTimeInterval(60*60*24*4))
        var year: Int = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitYear, fromDate: self.scheduleMonday)
        dateLabel.text = "\(mondayText) - \(fridayText), \(year)"
    }
    
    private func refreshScheduleNum(num: Int) {
        // Download today's schedule from the St. X website.
        var newTask: NSURLSessionTask = XScheduleDownloader.downloadSchedule(downloadDateForNum(num),
            completionHandler: { (output: String) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.handleCompletionOfDownload(output, num: num)
                }
            },
            errorHandler: { (errorText: String) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.handleError(errorText, num: num)
                }
            }
        )
        
        tasks.append(newTask)
    }
    private func handleCompletionOfDownload(output: String, num: Int) {
        var schedule: Schedule = parseStringForSchedule(output)

        displayScheduleInTable(schedule, num: num)
        
        displayTitleForSchedule(schedule, titleLabel: titleLabel(num))
        
        displayEmptyLabelForSchedule(schedule, emptyLabel: emptyLabel(num))
        
        oneTaskIsFinished()
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
        if (NSCalendar.currentCalendar().isDateInWeekend(scheduleDate)) {
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
            emptyLabel = self.blankLabel1
        case 2:
            emptyLabel = self.blankLabel2
        case 3:
            emptyLabel = self.blankLabel3
        case 4:
            emptyLabel = self.blankLabel4
        case 5:
            emptyLabel = self.blankLabel5
        default:
            return UILabel()
        }
        
        return emptyLabel
    }
    private func downloadDateForNum(num: Int) -> NSDate {
        var downloadDate: NSDate = scheduleMonday.dateByAddingTimeInterval(Double(24*60*60*(num-1)))
        
        return downloadDate
    }
    
    private func oneTaskIsFinished() {
        //Stop loading indicator after everything is complete.
        finishedLoadingNum++
        if(finishedLoadingNum>=5) {
            finishedLoadingNum = 0
            loadingIndicator.stopAnimating()
            
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
        tasks = []
    }
    
    private func handleError(errorText: String, num: Int) {
        displayAlertWithText(errorText)
        oneTaskIsFinished()
    }
    
    @IBAction func onBackButtonPress(sender: AnyObject) {
        cancelRequests()
        scheduleDate = scheduleDate.dateByAddingTimeInterval(-24*60*60*7)
    }
    @IBAction func onForwardButtonPress(sender: AnyObject) {
        cancelRequests()
        scheduleDate = scheduleDate.dateByAddingTimeInterval(24*60*60*7)
    }
    
    @IBAction func onTodayButtonPress(sender: AnyObject) {
        scheduleDate = NSDate()
    }
    
}
