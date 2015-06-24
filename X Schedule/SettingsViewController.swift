//
//  SettingsViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 6/18/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit
import XScheduleKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var substitutionSwitch: UISwitch!
    
    private var internalCellColor: UIColor = UIColor(red: (225.0/255.0), green: (238.0/255.0), blue: (254.0/255.0), alpha: 1.0)
    
    override func viewDidLoad() {
        substitutionSwitch.setOn(SubstitutionManager.getEnabled(), animated: false)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell: UITableViewCell? = tableView.cellForRowAtIndexPath(indexPath)
        if let cell = selectedCell {
            if (cell.tag == 501) { //Clear Cache button.
                clearCache()
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    private func clearCache() {
        CacheManager.clearCache()
        CacheManager.buildCache()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //Fixes background color on iPad.
        cell.backgroundColor = internalCellColor
    }
    
    @IBAction func substitutionSwitchToggle(sender: AnyObject) {
        SubstitutionManager.setEnabled(substitutionSwitch.on)
        refreshSchedule()
    }
    private func refreshSchedule() {
        getAppDelegate().refreshSchedule()
    }
    private func getAppDelegate() -> AppDelegate {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        return appDelegate
    }
    
}