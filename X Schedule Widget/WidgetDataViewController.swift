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
        // Do any additional setup after loading the view from its nib.
        
        scheduleDate = NSDate()
    }
    override func refreshSchedule() {
        
        // Download today's schedule from the St. X website.
        XScheduleDownloader.downloadSchedule(NSDate(),
            completionHandler: { (output: String) in
                //Execute code in main thread.
                dispatch_async(dispatch_get_main_queue()) {
                    
                    var parser = ScheduleParser()
                    var schedule = parser.parseForSchedule(output, date: NSDate())
                    
                    //Display schedule items in table.
                    if let tableController = self.childViewControllers[0] as? ScheduleTableController {
                        
                        tableController.displaySchedule(schedule)
                        
                        self.correctlySizeWidget(tableController.tableView)
                        
                        //Hide schedule table lines if schedule is blank.
                        if (schedule.items.isEmpty) {
                            tableController.view.hidden = true
                        }
                    }
                    
                    self.displayEmptyLabel(schedule)
                    
                }
            }
        )
    }
    private func correctlySizeWidget(tableView: UITableView) {
        if (tableView.contentSize.height > self.emptyLabel.frame.height){
            self.preferredContentSize = tableView.contentSize
        } else {
            self.preferredContentSize = self.emptyLabel.frame.size
        }
    }
    private func displayEmptyLabel(schedule: Schedule) {
        if (schedule.items.isEmpty) {
            self.emptyLabel.text = "No classes"
        } else {
            self.emptyLabel.text = ""
        }
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
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
