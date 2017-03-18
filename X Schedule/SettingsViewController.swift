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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell: UITableViewCell? = tableView.cellForRow(at: indexPath)
        if let cell = selectedCell {
            if (cell.tag == 501) { //Clear Cache button.
                clearCache()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    private func clearCache() {
        CacheManager.clearCache()
        CacheManager.buildCache()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //Fixes background color on iPad.
        cell.backgroundColor = internalCellColor
    }
    
    @IBAction func substitutionSwitchToggle(_ sender: AnyObject) {
        SubstitutionManager.setEnabled(substitutionSwitch.isOn)
        refreshSchedule()
    }
    private func refreshSchedule() {
        getAppDelegate().refreshSchedule()
    }
    private func getAppDelegate() -> AppDelegate {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate
    }
    
}
