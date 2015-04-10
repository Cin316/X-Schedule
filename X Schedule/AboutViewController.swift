//
//  AboutViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 3/7/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit

class AboutViewController: UITableViewController, UITableViewDelegate {
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String {
            versionLabel.text = version
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell: UITableViewCell? = tableView.cellForRowAtIndexPath(indexPath)
        if let cell = selectedCell {
            if (cell.tag == 200) { //GitHub link
                var url: NSURL = NSURL(string: "http://github.com/Cin316/X-Schedule")!
                UIApplication.sharedApplication().openURL(url)
            } else if (cell.tag == 201) { //St. X link
                var url: NSURL = NSURL(string: "http://www.stxavier.org/")!
                UIApplication.sharedApplication().openURL(url)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //Fix background color on iPad.
        cell.backgroundColor = UIColor(red: (225.0/255.0), green: (238.0/255.0), blue: (254.0/255.0), alpha: 1.0)
    }
}