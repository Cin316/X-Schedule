//
//  AboutViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 3/7/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit
import XScheduleKit

class AboutViewController: UITableViewController, UITableViewDelegate {
    
    @IBOutlet weak var versionLabel: UILabel!
    
    private var cellColor: UIColor = UIColor(red: (225.0/255.0), green: (238.0/255.0), blue: (254.0/255.0), alpha: 1.0)
    
    var versionNumber: String = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
    var buildNumber: String = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayVersionNumber()
    }
    private func displayVersionNumber() {
        versionLabel.text = "\(versionNumber) (\(buildNumber))"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell: UITableViewCell? = tableView.cellForRowAtIndexPath(indexPath)
        if let cell = selectedCell {
            if (cell.tag == 200) { //GitHub link
                openURL("http://github.com/Cin316/X-Schedule")
            } else if (cell.tag == 201) { //St. X link
                openURL("http://www.stxavier.org/")
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    private func openURL(url: String) {
        var url: NSURL = NSURL(string: url)!
        UIApplication.sharedApplication().openURL(url)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //Fix background color on iPad.
        cell.backgroundColor = cellColor
    }
}
