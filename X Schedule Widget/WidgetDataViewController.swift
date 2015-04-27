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

class WidgetDataViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var emptyLabel: UILabel!
    
    var lastUpdated = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        refreshSchedule()
    }
    
    private func refreshSchedule() {
        
        // Download today's schedule from the St. X website.
        XScheduleDownloader.downloadSchedule(NSDate(),
            completionHandler: { (output: String) in
                //Execute code in main thread.
                dispatch_async(dispatch_get_main_queue()) {
                    
                    var parser = ScheduleParser()
                    //Parse the downloaded code for schedule.
                    var schedule = parser.parseForSchedule(output, date: NSDate())
                    
                    //Display schedule items in table.
                    if let tableController = self.childViewControllers[0] as? ScheduleTableController {
                        tableController.schedule = schedule
                        let tableView = (tableController.view as? UITableView)!
                        tableView.reloadData()
                        
                        //Size widget correctly.
                        if (tableView.contentSize.height > self.emptyLabel.frame.height){
                            self.preferredContentSize = tableView.contentSize
                        } else {
                            self.preferredContentSize = self.emptyLabel.frame.size
                        }
                        
                        //Hide schedule table if schedule is blank.
                        if (schedule.items.isEmpty) {
                            tableView.hidden = true
                        }
                    }
                    
                    //Empty label
                    if (schedule.items.isEmpty) {
                        self.emptyLabel.text = "No classes"
                    } else {
                        self.emptyLabel.text = ""
                    }
                    
                }
            }
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        //Update every 3 hours.
        var secondsBetween = lastUpdated.timeIntervalSinceDate(NSDate())//Seconds since last update.
        if (secondsBetween > 60*60*3){
            completionHandler(NCUpdateResult.NewData)
        } else {
            completionHandler(NCUpdateResult.NoData)
        }
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, -1, 0)
    }
}
