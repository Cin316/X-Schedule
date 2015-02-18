//
//  DataViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/13/15.
//  Copyright (c) 2015 Nicholas Reichert. All rights reserved.
//

import UIKit

class DataViewController: UIViewController {
    
    @IBOutlet weak var displayBox: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Download today's schedule from the St. X website.
        /*ScheduleDownloader.downloadSchedule(
            { (output: String) in
                //Execute UI code in main thread.
                dispatch_async(dispatch_get_main_queue()) {
                    self.displayBox.text = output
                }
            }
        )*/
        
        var items: [ScheduleItem] = []
        var schedule = Schedule(items: items)
        displaySchedule(schedule)
    }
    
    func displaySchedule (schedule: Schedule) {
        var outputString = ""
        var dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "h:mm"
        for item in schedule.items {
            var startString = dateFormat.stringFromDate(item.startTime)
            var endString = dateFormat.stringFromDate(item.endTime)
            outputString += "\(item.blockName): \(startString) - \(endString)\n"
        }
        self.displayBox.text = outputString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

