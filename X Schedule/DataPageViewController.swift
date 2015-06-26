//
//  DataPageViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 6/26/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit
import XScheduleKit

class DataPageViewController: UIPageViewController {
    override func viewDidLoad() {
        
    }
}

class DataPageViewControllerDataSource: NSObject, UIPageViewControllerDataSource {
    private static let scheduleIdentifier = "ColoredScheduleTableViewController"
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var outputController: ScheduleTableController?
        if let tableController = viewController as? ScheduleTableController {
            var date: NSDate = tableController.schedule.date.dateByAddingTimeInterval(-24*60*60)
            outputController = newScheduleTableForDate(date, pageController: pageViewController)
        }
        
        return outputController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var outputController: ScheduleTableController?
        if let tableController = viewController as? ScheduleTableController {
            var date: NSDate = tableController.schedule.date.dateByAddingTimeInterval(24*60*60)
            outputController = newScheduleTableForDate(date, pageController: pageViewController)
        }
        
        return outputController
    }
    
    private func newScheduleTableForDate(date: NSDate, pageController: UIPageViewController) -> ScheduleTableController? {
        var newTable: ScheduleTableController? = pageController.storyboard!.instantiateViewControllerWithIdentifier(DataPageViewControllerDataSource.scheduleIdentifier) as! ScheduleTableController?
        //TODO Generate schedule.
        newTable!.schedule = Schedule()
        
        return newTable
    }
    
}