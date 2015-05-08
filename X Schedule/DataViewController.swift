//
//  DataViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/13/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit
import XScheduleKit

class DataViewController: ScheduleViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshSchedule()
    }
    
    override func refreshSchedule() {
        //Start loading indicator before download.
        loadingIndicator.startAnimating()
        
        // Download today's schedule from the St. X website.
        XScheduleDownloader.downloadSchedule(scheduleDate,
            completionHandler: { (output: String) in
                //Execute code in main thread.
                dispatch_async(dispatch_get_main_queue()) {
                    self.handleCompletionOfDownload(output)
                    
                }
            },
            errorHandler: { (errorText: String) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.handleError(errorText)
                }
            }
        )
    }
    
    private func handleCompletionOfDownload(output: String) {
        var schedule: Schedule = parseStringForSchedule(output)
        
        displayScheduleInTable(schedule)
        
        displayTitleForSchedule(schedule)
        
        displayDateLabelForDate(scheduleDate)
        
        displayEmptyLabelForSchedule(schedule)
        
        loadingIndicator.stopAnimating()
    }
    private func parseStringForSchedule(string: String) -> Schedule {
        var parser: ScheduleParser = ScheduleParser()
        var schedule: Schedule = parser.parseForSchedule(string, date: scheduleDate)
    
        return schedule
    }
    private func displayScheduleInTable(schedule: Schedule) {
        if let tableController = childViewControllers[0] as? ScheduleTableController {
            tableController.schedule = schedule
            let tableView = (tableController.view as? UITableView)!
            tableView.reloadData()
        }
    }
    private func displayTitleForSchedule(schedule: Schedule) {
        //Display normal title.
        titleLabel.text = schedule.title
        
        //Add default weekend title if needed.
        if (NSCalendar.currentCalendar().isDateInWeekend(scheduleDate)) {
            titleLabel.text = "Weekend"
        }
    }
    private func displayEmptyLabelForSchedule(schedule: Schedule) {
        if (schedule.items.isEmpty) {
            emptyLabel.text = "No classes"
        } else {
            emptyLabel.text = ""
        }
    }
    
    private func displayDateLabelForDate(date: NSDate) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        dateLabel.text = dateFormatter.stringFromDate(date)
    }
    
    private func handleError(errorText: String) {
        displayAlertWithText(errorText)
        loadingIndicator.stopAnimating()
        displayDateLabelForDate(scheduleDate)
        titleLabel.text = "Error"
    }
    private func displayAlertWithText(message: String) {
        var alert = createAlertWithText(message)
        displayAlert(alert)
    }
    private func createAlertWithText(message: String) -> UIAlertController {
        //Creates an alert with provided text and an "OK" button that closes the alert.
        var alert: UIAlertController = UIAlertController(title: message, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: {})
        }))
        
        return alert
    }
    private func displayAlert(alert: UIAlertController) {
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func onBackButtonPress(sender: AnyObject) {
        scheduleDate = scheduleDate.dateByAddingTimeInterval(-24*60*60)
    }
    @IBAction func onForwardButtonPress(sender: AnyObject) {
        scheduleDate = scheduleDate.dateByAddingTimeInterval(24*60*60)
    }
    
    @IBAction func onTodayButtonPress(sender: AnyObject) {
        scheduleDate = NSDate()
    }
}

