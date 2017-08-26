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
    
    var scheduleMonday: Date {
        get {
            let calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let weekday: Int = (calendar as NSCalendar).component(.weekday, from: scheduleDate)
            let daysPastMonday: Int = weekday-2
            let seconds: Double = Double(-24*60*60*daysPastMonday)
            return scheduleDate.addingTimeInterval(seconds)
        }
    }
    
    var tasks: [URLSessionTask] = []
    var downloadMethods: [DownloadMethod] = [DownloadMethod](repeating: DownloadMethod.cache, count: 5)
    var downloadCount: Int {
        get {
            var num: Int = 0
            for method in downloadMethods {
                if (method == DownloadMethod.download) {
                    num += 1
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
        let blankSchedule: Schedule = Schedule()
        for i in 0...4 {
            if let tableController = self.childViewControllers[i] as? ScheduleTableController {
                if (downloadMethods[i] == DownloadMethod.download) {
                    tableController.schedule = blankSchedule
                }
            }
        }
    }
    private func clearEmptyLabels() {
        //Clear all "No classes" labels.
        for i in 1...5 {
            emptyLabel(i).text = ""
        }
    }
    private func refreshSchedules() {
        //Refresh schedule for each day of the week.
        for i in 1...5 {
            refreshScheduleNum(i)
        }
    }
    
    private func displayDateLabel() {
        dateLabel.text = dateLabelText()
    }
    private func dateLabelText() -> String {
        //Display correctly formatted date label.
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        
        let mondayText: String = dateFormatter.string(from: self.scheduleMonday)
        let fridayText: String = dateFormatter.string(from: self.scheduleMonday.addingTimeInterval(60*60*24*4))
        
        let year: Int = (Calendar.current as NSCalendar).component(NSCalendar.Unit.year, from: self.scheduleMonday)
        
        return "\(mondayText) - \(fridayText), \(year)"
    }
    
    private func refreshScheduleNum(_ num: Int) {
        // Download today's schedule from the St. X website.
        let downloadResult = XScheduleManager.getScheduleForDate(downloadDateForNum(num),
            completionHandler: { (schedule: Schedule) in
                DispatchQueue.main.async {
                    self.handleCompletionOfDownload(schedule, num: num)
                }
            },
            errorHandler: { (errorText: String) in
                DispatchQueue.main.async {
                    self.handleError(errorText, num: num)
                }
            }, method: .download
        )
        
        let newTask: URLSessionTask? = downloadResult.1
        let methodUsed: DownloadMethod = downloadResult.0
        
        downloadMethods[num-1] = methodUsed
        
        if (newTask != nil) {
            tasks.append(newTask!)
        }
    }
    private func handleCompletionOfDownload(_ schedule: Schedule, num: Int) {
        displayScheduleInTable(schedule, num: num)
        displayTitleForSchedule(schedule, titleLabel: titleLabel(num))
        displayEmptyLabelForSchedule(schedule, emptyLabel: emptyLabel(num))
        markOneTaskAsFinished()
    }
    private func displayScheduleInTable(_ schedule: Schedule, num: Int) {
        if let tableController = childViewControllers[num-1] as? ScheduleTableController {
            tableController.displaySchedule(schedule)
        }
    }
    private func displayTitleForSchedule(_ schedule: Schedule, titleLabel: UILabel) {
        //Display normal title.
        titleLabel.text = schedule.title
        
        //Add default weekend title if needed.
        if (Calendar.current.isDateInWeekend(scheduleMonday)) {
            titleLabel.text = "Weekend"
        }
    }
    private func displayEmptyLabelForSchedule(_ schedule: Schedule, emptyLabel: UILabel) {
        if (schedule.items.isEmpty) {
            emptyLabel.text = "No classes"
        } else {
            emptyLabel.text = ""
        }
    }
    
    private func titleLabel(_ num: Int) -> UILabel {
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
    private func emptyLabel(_ num: Int) -> UILabel {
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
    private func downloadDateForNum(_ num: Int) -> Date {
        let downloadDate: Date = scheduleMonday.addingTimeInterval(Double(24*60*60*(num-1)))
        
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
        finishedLoadingNum += 1
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
    
    private func handleError(_ errorText: String, num: Int) {
        displayAlertWithText(errorText)
        markOneTaskAsFinished()
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
