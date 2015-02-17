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
        displayBox.text = "This works"
        // Download today's schedule from the St. X website.
        ScheduleDownloader.downloadSchedule(
            { (output: String) in
                //Execute UI code in main thread.
                dispatch_async(dispatch_get_main_queue()) {
                    self.displayBox.text = output
                }
            }
        )
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

