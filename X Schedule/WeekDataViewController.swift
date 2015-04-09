//
//  WeekDataViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 4/4/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit

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
            var calendar: NSCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
            var weekday: Int = calendar.component(.CalendarUnitWeekday, fromDate: scheduleDate)
            var daysPastMonday: Int = weekday-2
            var seconds: Double = Double(-24*60*60*daysPastMonday)
            return scheduleDate.dateByAddingTimeInterval(seconds)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        refreshSchedule()
    }
    
    private func refreshSchedule() {
        //Start loading indicator before download.
        loadingIndicator.startAnimating()
        finishedLoadingNum = 0
        
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
        dateLabel.text = "\(mondayText) - \(fridayText)"
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
        ScheduleDownloader.downloadSchedule(downloadDate,
            { (output: String) in
                //Execute code in main thread.
                dispatch_async(dispatch_get_main_queue()) {
                    var parser = ScheduleParser()
                    //Parse the downloaded code for schedule.
                    var schedule = parser.parseForSchedule(output)
                    //Display schedule items in table.
                    if let tableController = self.childViewControllers[num-1] as? ScheduleTableController {
                        tableController.schedule = schedule
                        let tableView = (tableController.view as? UITableView)!
                        tableView.reloadData()
                    }
                    
                    //Display title.
                    titleLabel.text = schedule.title
                    
                    //Add default weekend title.
                    var weekday = NSCalendar.currentCalendar().component(.CalendarUnitWeekday, fromDate: downloadDate)
                    if ((weekday==1 || weekday==7) && schedule.title==""){
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
                    }
                    
                }
            }
        )
    }
    
    @IBAction func onBackButtonPress(sender: AnyObject) {
        scheduleDate = scheduleDate.dateByAddingTimeInterval(-24*60*60*7)
        refreshSchedule()
    }
    @IBAction func onForwardButtonPress(sender: AnyObject) {
        scheduleDate = scheduleDate.dateByAddingTimeInterval(24*60*60*7)
        refreshSchedule()
    }
    
}