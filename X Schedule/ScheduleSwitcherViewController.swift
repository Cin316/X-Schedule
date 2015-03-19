//
//  ScheduleSwitcherViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 3/16/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit

class ScheduleSwitcherViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.performSegueWithIdentifier("displayScheduleiPhone", sender: self)
        self.title = "Schedule"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
