//
//  AboutViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 3/7/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit

class AboutViewController: UITableViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String {
            versionLabel.text = version;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}