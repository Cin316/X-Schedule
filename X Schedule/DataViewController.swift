//
//  DataViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/13/15.
//  Copyright (c) 2015 Nicholas Reichert. All rights reserved.
//

import UIKit

class DataViewController: UIViewController {
    
    @IBOutlet weak var scheduleDate: UILabel!
    @IBOutlet weak var scheduleTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Download today's schedule from the St. X website.
        ScheduleDownloader.downloadSchedule(
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
                    }
                    //Display title.
                    self.scheduleTitle.text = schedule.title
                    //Display correctly formatted date.
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "EEEE, MMMM d"
                    self.scheduleDate.text = dateFormatter.stringFromDate(schedule.date)

                }
            }
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

