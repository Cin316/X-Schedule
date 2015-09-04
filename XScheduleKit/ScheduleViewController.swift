//
//  ScheduleViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 5/3/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit

public class ScheduleViewController: UIViewController {
    
    private let daysPerView: Int = 1
    public func numberOfDaysPerView() -> Int {
        return daysPerView
    }
    
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
    
    public func parseStringForSchedule(string: String) -> Schedule {
        var schedule: Schedule = XScheduleParser.parseForSchedule(string, date: scheduleDate)
        
        return schedule
    }
    
    public func displayAlertWithText(message: String) {
        var alert = createAlertWithText(message)
        displayAlert(alert)
    }
    public func createAlertWithText(message: String) -> UIAlertController {
        //Creates an alert with provided text and an "OK" button that closes the alert.
        var alert: UIAlertController = UIAlertController(title: message, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: {})
        }))
        
        return alert
    }
    public func displayAlert(alert: UIAlertController) {
        presentViewController(alert, animated: true, completion: nil)
    }
    
    public func onBackButtonPress(sender: AnyObject) {
        scheduleDate = scheduleDate.dateByAddingTimeInterval(Double(-24*60*60*numberOfDaysPerView()))
    }
    public func onForwardButtonPress(sender: AnyObject) {
        scheduleDate = scheduleDate.dateByAddingTimeInterval(Double(24*60*60*numberOfDaysPerView()))
    }
    
    public func onTodayButtonPress(sender: AnyObject) {
        scheduleDate = NSDate()
    }
    
}
