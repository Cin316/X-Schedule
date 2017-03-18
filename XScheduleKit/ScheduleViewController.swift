//
//  ScheduleViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 5/3/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit

open class ScheduleViewController: UIViewController {
    
    private let daysPerView: Int = 1
    open func numberOfDaysPerView() -> Int {
        return daysPerView
    }
    
    open var initialized: Bool = false
    
    open var scheduleDate: Date = Date() {
        didSet {
            if (oldValue != scheduleDate) {
                refreshScheduleIfReady()
            }
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        initialized = true
    }
    
    private func refreshScheduleIfReady() {
        if (initialized) {
            refreshSchedule()
        }
    }
    
    open func refreshSchedule() {
    
    }
    
    open func parseStringForSchedule(_ string: String) -> Schedule {
        let schedule: Schedule = XScheduleParser.parseForSchedule(string, date: scheduleDate)
        
        return schedule
    }
    
    open func displayAlertWithText(_ message: String) {
        let alert = createAlertWithText(message)
        displayAlert(alert)
    }
    open func createAlertWithText(_ message: String) -> UIAlertController {
        //Creates an alert with provided text and an "OK" button that closes the alert.
        let alert: UIAlertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            alert.dismiss(animated: true, completion: {})
        }))
        
        return alert
    }
    open func displayAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    open func onBackButtonPress(_ sender: AnyObject) {
        scheduleDate = scheduleDate.addingTimeInterval(Double(-24*60*60*numberOfDaysPerView()))
    }
    open func onForwardButtonPress(_ sender: AnyObject) {
        scheduleDate = scheduleDate.addingTimeInterval(Double(24*60*60*numberOfDaysPerView()))
    }
    
    open func onTodayButtonPress(_ sender: AnyObject) {
        scheduleDate = Date()
    }
    
}
