//
//  ScheduleViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 5/3/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit

public class ScheduleViewController: UIViewController {
    
    public var initialized: Bool = false
    
    public var scheduleDate: NSDate = NSDate() {
        didSet {
            if (oldValue != scheduleDate) {
                refreshScheduleIfReady()
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        initialized = true
    }
    
    private func refreshScheduleIfReady() {
        if (initialized) {
            refreshSchedule()
        }
    }
    
    public func refreshSchedule() {
    
    }
    
}