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
    func emptyUILabel() -> UILabel? {
        return emptyLabel
    }
    
    func tableController() -> ScheduleTableController? {
        return childViewControllers[0] as? ScheduleTableController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshSchedule()
    }
    
    override func refreshSchedule() {
        // Download today's schedule from the St. X website.
        let downloadResult: (DownloadMethod, URLSessionTask?) =
        XScheduleManager.getScheduleForDate(scheduleDate,
            completionHandler: { (schedule: Schedule) in
                //Execute code in main thread.
                DispatchQueue.main.async {
                    self.handleCompletionOfDownload(schedule)
                    
                }
            },
            errorHandler: { (errorText: String) in
                DispatchQueue.main.async {
                    self.handleError(errorText)
                }
            },
            method: .auto
        )
        let methodUsed: DownloadMethod = downloadResult.0
        
        if (methodUsed == .download) {
            startLoading()
        }
        
    }
    
    private func handleCompletionOfDownload(_ schedule: Schedule) {
        displayScheduleInTable(schedule)
        displayTitleForSchedule(schedule)
        displayDateLabelForDate(scheduleDate)
        displayEmptyLabelForSchedule(schedule)
        stopLoading()
    }
    private func displayScheduleInTable(_ schedule: Schedule) {
        if let tableController = tableController() {
            tableController.displaySchedule(schedule)
        }
    }
    private func displayTitleForSchedule(_ schedule: Schedule) {
        //Display normal title.
        titleLabel.text = schedule.title
        
        //Add default weekend title if needed.
        if (Calendar.current.isDateInWeekend(scheduleDate)) {
            titleLabel.text = "Weekend"
        }
    }
    private func displayEmptyLabelForSchedule(_ schedule: Schedule) {
        if let emptyText = emptyUILabel() {
            if (schedule.items.isEmpty) {
                emptyText.text = "No classes"
            } else {
                emptyText.text = ""
            }
        }
    }
    
    private func displayDateLabelForDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        dateLabel.text = dateFormatter.string(from: date)
    }
    
    internal func handleError(_ errorText: String) {
        displayAlertWithText(errorText)
        stopLoading()
        displayDateLabelForDate(scheduleDate)
        titleLabel.text = "Error"
    }
    
    private func startLoading() {
        loadingIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    private func stopLoading() {
        loadingIndicator.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
