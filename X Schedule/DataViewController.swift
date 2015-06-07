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
        var method: DownloadMethod = DownloadMethod.Download
        
        // Download today's schedule from the St. X website.
        XScheduleManager.getScheduleForDate(scheduleDate,
            completionHandler: { (schedule: Schedule) in
                //Execute code in main thread.
                dispatch_async(dispatch_get_main_queue()) {
                    self.handleCompletionOfDownload(schedule)
                    
                }
            },
            errorHandler: { (errorText: String) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.handleError(errorText)
                }
            },
            method: &method
        )
        if (method==DownloadMethod.Download) {
            startLoading()
        }
        
    }
    
    private func handleCompletionOfDownload(schedule: Schedule) {
        displayScheduleInTable(schedule)
        displayTitleForSchedule(schedule)
        displayDateLabelForDate(scheduleDate)
        displayEmptyLabelForSchedule(schedule)
        stopLoading()
    }
    private func displayScheduleInTable(schedule: Schedule) {
        if let tableController = childViewControllers[0] as? ScheduleTableController {
            tableController.displaySchedule(schedule)
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
        stopLoading()
        displayDateLabelForDate(scheduleDate)
        titleLabel.text = "Error"
    }
    
    private func startLoading() {
        loadingIndicator.startAnimating()
    }
    private func stopLoading() {
        loadingIndicator.stopAnimating()
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

