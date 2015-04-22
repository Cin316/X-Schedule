//
//  WeekDataViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 4/4/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit
import XScheduleKit

class WeekDataViewController: UIViewController {
    
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
    
    var scheduleDate: NSDate = NSDate()
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
    
    func refreshSchedule() {
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
        var titleLabel: UILabel!
        var emptyLabel: UILabel!
        var downloadDate = scheduleMonday.dateByAddingTimeInterval(Double(24*60*60*(num-1)))
        switch num {
        case 1:
            titleLabel = self.titleLabel1
            emptyLabel = self.blankLabel1
        case 2:
            titleLabel = self.titleLabel2
            emptyLabel = self.blankLabel2
        case 3:
            titleLabel = self.titleLabel3
            emptyLabel = self.blankLabel3
        case 4:
            titleLabel = self.titleLabel4
            emptyLabel = self.blankLabel4
        case 5:
            titleLabel = self.titleLabel5
            emptyLabel = self.blankLabel5
        default:
            return
        }
        
        // Download today's schedule from the St. X website.
        var newTask: NSURLSessionTask = ScheduleDownloader.downloadSchedule(downloadDate,
            completionHandler: { (output: String) in
                //Execute code in main thread.
                dispatch_async(dispatch_get_main_queue()) {
                    var parser = ScheduleParser()
                    //Parse the downloaded code for schedule.
                    var schedule = parser.parseForSchedule(output, date: downloadDate)
                    //Display schedule items in table.
                    if let tableController = self.childViewControllers[num-1] as? ScheduleTableController {
                        tableController.schedule = schedule
                        let tableView = (tableController.view as? UITableView)!
                        tableView.reloadData()
                    }
                    
                    //Display title.
                    titleLabel.text = schedule.title
                    
                    //Add default weekend title.
                    if (NSCalendar.currentCalendar().isDateInWeekend(self.scheduleDate)){
                        titleLabel.text = "Weekend"
                    }
                    
                    //Empty label
                    if (schedule.items.isEmpty) {
                        emptyLabel.text = "No classes"
                    } else {
                        emptyLabel.text = ""
                    }
                    
                    //Stop loading indicator after everything is complete.
                    self.finishedLoadingNum++
                    if(self.finishedLoadingNum==5) {
                        self.loadingIndicator.stopAnimating()
                        self.finishedLoadingNum = 0
                        
                        //Clear references to tasks from tasks.
                        self.tasks = []
                    }
                    
                }
            }
        )
        
        tasks.append(newTask)
    }
    
    @IBAction func onBackButtonPress(sender: AnyObject) {
        cancelRequests()
        scheduleDate = scheduleDate.dateByAddingTimeInterval(-24*60*60*7)
        refreshSchedule()
    }
    @IBAction func onForwardButtonPress(sender: AnyObject) {
        cancelRequests()
        scheduleDate = scheduleDate.dateByAddingTimeInterval(24*60*60*7)
        refreshSchedule()
    }
    
    private func cancelRequests() {
        for task in tasks {
            task.cancel()
        }
        tasks = []
    }
    
    @IBAction func onTodayButtonPress(sender: AnyObject) {
        scheduleDate = NSDate()
        refreshSchedule()
    }
    
}