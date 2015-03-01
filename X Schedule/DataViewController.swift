//
//  DataViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/13/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit

class DataViewController: UIViewController {
    
    var scheduleDate: NSDate = NSDate()
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titelLabel: UILabel!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        refreshSchedule()
    }
    
    private func refreshSchedule() {
        //Start loading indicator before download.
        loadingIndicator.startAnimating()
        
        // Download today's schedule from the St. X website.
        ScheduleDownloader.downloadSchedule(scheduleDate,
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
                    self.titelLabel.text = schedule.title
                    //Display correctly formatted date.
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "EEEE, MMMM d"
                    self.dateLabel.text = dateFormatter.stringFromDate(self.scheduleDate)
                    
                    //Stop loading indicator after everything is complete.
                    self.loadingIndicator.stopAnimating()
                    
                }
            }
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackButtonPress(sender: AnyObject) {
        scheduleDate = scheduleDate.dateByAddingTimeInterval(-24*60*60)
        refreshSchedule()
    }
    @IBAction func onForwardButtonPress(sender: AnyObject) {
        scheduleDate = scheduleDate.dateByAddingTimeInterval(24*60*60)
        refreshSchedule()
    }
    
}

