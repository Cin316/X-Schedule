//
//  DataViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/13/15.
//  Copyright (c) 2015 Nicholas Reichert. All rights reserved.
//

import UIKit

class DataViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Download today's schedule from the St. X website.
        ScheduleDownloader.downloadSchedule(
            { (output: String) in
                //Execute code in main thread.
                dispatch_async(dispatch_get_main_queue()) {
                    var parser = ScheduleParser()
                    var schedule = parser.parseForSchedule(output)
                    if let tableController = self.childViewControllers[0] as? ScheduleTableController {
                        tableController.schedule = schedule
                        let tableView = (tableController.view as? UITableView)!
                        tableView.reloadData()
                    }
                }
            }
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

