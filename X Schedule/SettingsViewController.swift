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
    
    override func viewDidLoad() {
        
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
    
}