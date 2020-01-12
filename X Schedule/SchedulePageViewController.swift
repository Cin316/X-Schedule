//
//  SchedulePageViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 7/15/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit
import XScheduleKit

class SchedulePageViewController: UIViewController {
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    var tableController: ScheduleTableController?
    var schedule: Schedule {
        get {
            if (loaded) {
                //Get schedule from tableController.
                return tableController!.schedule
            } else {
                //If not loaded, use tempSchedule.
                return tempSchedule
            }
        }
        set {
            if (loaded) {
                //Put schedule in tableController.
                DispatchQueue.main.async { // Can only do UI changes in the main thread
                    self.tableController?.displaySchedule(newValue)
                    self.fillEmptyLabel()
                }
            } else {
                //If not loaded, store temporarily.
                tempSchedule = newValue
            }
        }
    }
    private var tempSchedule: Schedule = Schedule()
    var loaded: Bool = false
    
    override func viewDidLoad() {
        loaded = true
        tableController = children.first as! ScheduleTableController?
        schedule = tempSchedule
        fillEmptyLabel()
    }
    
    private func fillEmptyLabel() {
        if (schedule.items.isEmpty) {
            emptyLabel.text = "No classes"
        } else {
            emptyLabel.text = ""
        }
    }
    
}
