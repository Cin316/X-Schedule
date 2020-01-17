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
    
    var lastUpdated = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Schedule date is 8 hours in the future so the schedule displays the next day's classes in the evenings.
        scheduleDate = Date().addingTimeInterval(60*60*8)
        if #available(iOSApplicationExtension 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
    }
    override func refreshSchedule() {
        // Download today's schedule from the St. X website.
        XScheduleManager.getScheduleForDate(scheduleDate,
            completionHandler: { (schedule: Schedule) in
                //Execute code in main thread.
                DispatchQueue.main.async {
                    self.handleCompletionOfDownload(schedule)
                }
            }
        )
    }
    private func handleCompletionOfDownload(_ schedule: Schedule) {
        displayScheduleInTable(schedule)
        displayEmptyLabelForSchedule(schedule)
    }
    
    private func displayScheduleInTable(_ schedule: Schedule) {
        //Display schedule items in table.
        if let tableController = children[0] as? ScheduleTableController {
            tableController.displaySchedule(schedule)
            if #available(iOSApplicationExtension 10.0, *) {
                
            } else {
                correctlySizeWidget(tableController.tableView)
            }
            hideIfEmpty(tableController, schedule: schedule)
        }
    }
    private func correctlySizeWidget(_ tableView: UITableView) {
        if (tableView.contentSize.height > self.emptyLabel.frame.height){
            self.preferredContentSize = tableView.contentSize
        } else {
            self.preferredContentSize = self.emptyLabel.frame.size
        }
    }
    private func displayEmptyLabelForSchedule(_ schedule: Schedule) {
        if (schedule.items.isEmpty) {
            self.emptyLabel.text = "No classes"
        } else {
            self.emptyLabel.text = ""
        }
    }
    private func hideIfEmpty(_ tableController: UIViewController, schedule: Schedule) {
        //Hide schedule table lines if schedule is blank.
        if (schedule.items.isEmpty) {
            tableController.view.isHidden = true
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        //Update every 3 hours.
        let secondsSinceLastUpdate = lastUpdated.timeIntervalSince(Date())
        if (secondsSinceLastUpdate > 60*60*3){
            completionHandler(NCUpdateResult.newData)
        } else {
            completionHandler(NCUpdateResult.noData)
        }
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: -1, right: 0)
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if let tableController = children[0] as? ScheduleTableController {
            if (activeDisplayMode == .expanded) {
                correctlySizeWidget(tableController.tableView)
            } else {
                self.preferredContentSize = maxSize
            }
        }
    }
    
}
