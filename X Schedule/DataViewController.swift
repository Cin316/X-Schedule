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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        refreshSchedule()
    }
    
    override func refreshSchedule() {
        //Start loading indicator before download.
        loadingIndicator.startAnimating()
        
        // Download today's schedule from the St. X website.
        XScheduleDownloader.downloadSchedule(scheduleDate,
            completionHandler: { (output: String) in
                //Execute code in main thread.
                dispatch_async(dispatch_get_main_queue()) {
                    var parser = ScheduleParser()
                    //Parse the downloaded code for schedule.
                    var schedule = parser.parseForSchedule(output, date: self.scheduleDate)
                    //Display schedule items in table.
                    if let tableController = self.childViewControllers[0] as? ScheduleTableController {
                        tableController.schedule = schedule
                        let tableView = (tableController.view as? UITableView)!
                        tableView.reloadData()
                    }
                    //Display title.
                    self.titleLabel.text = schedule.title
                    //Display correctly formatted date.
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
                    self.dateLabel.text = dateFormatter.stringFromDate(self.scheduleDate)
                    
                    //Add default weekend title.
                    if (NSCalendar.currentCalendar().isDateInWeekend(self.scheduleDate)){
                        self.titleLabel.text = "Weekend"
                    }
                    
                    //Empty label
                    if (schedule.items.isEmpty) {
                        self.emptyLabel.text = "No classes"
                    } else {
                        self.emptyLabel.text = ""
                    }

                    //Stop loading indicator after everything is complete.
                    self.loadingIndicator.stopAnimating()
                    
                }
            },
            errorHandler: { (errorText: String) in
                dispatch_async(dispatch_get_main_queue()) {
                    
                    //Display error.
                    var alert = UIAlertController(title: errorText, message: nil, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                        alert.dismissViewControllerAnimated(true, completion: {})
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    //Stop loading indicator.
                    self.loadingIndicator.stopAnimating()
                    
                    //Display correctly formatted date.
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
                    self.dateLabel.text = dateFormatter.stringFromDate(self.scheduleDate)
                    
                    self.titleLabel.text = "Error"
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
    }
    @IBAction func onForwardButtonPress(sender: AnyObject) {
        scheduleDate = scheduleDate.dateByAddingTimeInterval(24*60*60)
    }
    
    @IBAction func onTodayButtonPress(sender: AnyObject) {
        scheduleDate = NSDate()
    }
}

