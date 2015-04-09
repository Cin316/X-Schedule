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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        refreshSchedule()
    }
    
    private func refreshSchedule() {
        
        // Download today's schedule from the St. X website.
        ScheduleDownloader.downloadSchedule(NSDate(),
            { (output: String) in
                //Execute code in main thread.
                dispatch_async(dispatch_get_main_queue()) {
                    
                    var parser = ScheduleParser()
                    //Parse the downloaded code for schedule.
                    var schedule = parser.parseForSchedule(output)
                    
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

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
}
