//
//  WidgetDataViewController.swift
//  X Schedule Widget
//
//  Created by Nicholas Reichert on 4/8/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit
import NotificationCenter
import XScheduleKit

class WidgetDataViewController: ScheduleViewController, NCWidgetProviding {
        
    @IBOutlet weak var emptyLabel: UILabel!
    
    var lastUpdated = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scheduleDate = NSDate()
    }
    override func refreshSchedule() {
        // Download today's schedule from the St. X website.
        XScheduleDownloader.downloadSchedule(NSDate(),
            completionHandler: { (output: String) in
                //Execute code in main thread.
                dispatch_async(dispatch_get_main_queue()) {
                    self.handleCompletionOfDownload(output)
                }
            }
        )
    }
    private func handleCompletionOfDownload(output: String) {
        var schedule: Schedule = parseStringForSchedule(output)
        
        displayScheduleInTable(schedule)
        
        displayEmptyLabelForSchedule(schedule)
    }
    private func parseStringForSchedule(string: String) -> Schedule {
        var parser: ScheduleParser = ScheduleParser()
        var schedule: Schedule = parser.parseForSchedule(string, date: scheduleDate)
        
        return schedule
    }
    private func displayScheduleInTable(schedule: Schedule) {
        //Display schedule items in table.
        if let tableController = childViewControllers[0] as? ScheduleTableController {
            tableController.displaySchedule(schedule)
            correctlySizeWidget(tableController.tableView)
            hideIfEmpty(tableController, schedule: schedule)
        }
    }
    private func correctlySizeWidget(tableView: UITableView) {
        if (tableView.contentSize.height > self.emptyLabel.frame.height){
            self.preferredContentSize = tableView.contentSize
        } else {
            self.preferredContentSize = self.emptyLabel.frame.size
        }
    }
    private func displayEmptyLabelForSchedule(schedule: Schedule) {
        if (schedule.items.isEmpty) {
            self.emptyLabel.text = "No classes"
        } else {
            self.emptyLabel.text = ""
        }
    }
    private func hideIfEmpty(tableController: UIViewController, schedule: Schedule) {
        //Hide schedule table lines if schedule is blank.
        if (schedule.items.isEmpty) {
            tableController.view.hidden = true
        }
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        //Update every 3 hours.
        var secondsSinceLastUpdate = lastUpdated.timeIntervalSinceDate(NSDate())
        if (secondsSinceLastUpdate > 60*60*3){
            completionHandler(NCUpdateResult.NewData)
        } else {
            completionHandler(NCUpdateResult.NoData)
        }
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, -1, 0)
    }
}
