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
    var pageDelegate: DataPageViewControllerDelegate?
    var pageDataSource: DataPageViewControllerDataSource?
    
    override func viewDidLoad() {
        pageDataSource = DataPageViewControllerDataSource(viewController: self)
        self.dataSource = pageDataSource
        
        pageDelegate = DataPageViewControllerDelegate(viewController: self)
        self.delegate = pageDelegate
        
        var initialController = self.storyboard!.instantiateViewControllerWithIdentifier(DataPageViewControllerDataSource.scheduleIdentifier) as! ScheduleTableController
        self.setViewControllers([initialController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: {(bool: Bool) in })
    }
    
    func flipPageInDirection(direction: UIPageViewControllerNavigationDirection, withDate date: NSDate) {
        var newController = self.storyboard!.instantiateViewControllerWithIdentifier(DataPageViewControllerDataSource.scheduleIdentifier) as! ScheduleTableController
        XScheduleManager.getScheduleForDate(date,
            completionHandler: {(schedule: Schedule) in
                newController.schedule = schedule
            },
            errorHandler: {(errorText: String) in
                //println("\(errorText)")
                // TODO Handle error.
            }
        )
        self.setViewControllers([newController], direction: direction, animated: true, completion: {(bool: Bool) in })
    }
    
    func getDataController() -> DataViewController {
        return self.parentViewController as! DataViewController
    }
}

class DataPageViewControllerDataSource: NSObject, UIPageViewControllerDataSource {
    
    private static let scheduleIdentifier = "ColoredScheduleTableViewController"
    weak var parentController: DataPageViewController?
    
    init(viewController: DataPageViewController) {
        parentController = viewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return getNewViewController(pageViewController, viewController: viewController, direction: UIPageViewControllerNavigationDirection.Reverse)
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return getNewViewController(pageViewController, viewController: viewController, direction: UIPageViewControllerNavigationDirection.Forward)
    }
    
    func getNewViewController(pageViewController: UIPageViewController, viewController: UIViewController, direction: UIPageViewControllerNavigationDirection) -> UIViewController? {
        //Makes a new, blank ScheduleTableController.
        var outputController = pageViewController.storyboard!.instantiateViewControllerWithIdentifier(DataPageViewControllerDataSource.scheduleIdentifier) as! ScheduleTableController!
        
        //Set the right date in the table.
        outputController.schedule.date = dateForNextSchedule(viewController as! ScheduleTableController, direction: direction)
        
        //Populate table with schedule.
        XScheduleManager.getScheduleForDate(outputController.schedule.date,
            completionHandler: {(schedule: Schedule) in
                outputController.schedule = schedule
            },
            errorHandler: {(errorText: String) in
                //println("\(errorText)")
                // TODO Handle error.
            }
        )
        
        return outputController
    }
    
    private func dateForNextSchedule(previousController: ScheduleTableController, direction: UIPageViewControllerNavigationDirection) -> NSDate {
        var oldDate: NSDate = previousController.schedule.date
        var timeCoeff: Double = (direction == UIPageViewControllerNavigationDirection.Forward) ? 1.0 : -1.0
        var newDate: NSDate = oldDate.dateByAddingTimeInterval(timeCoeff*60*60*24)
        
        return newDate
    }
    
}

class DataPageViewControllerDelegate: NSObject, UIPageViewControllerDelegate {
    
    weak var parentController: DataPageViewController?
    
    init(viewController: DataPageViewController) {
        parentController = viewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        if (completed) {
            var newViewController: ScheduleTableController = pageViewController.viewControllers.first! as! ScheduleTableController
            var newDate: NSDate = newViewController.schedule.date
            parentController?.getDataController().scheduleDate = newDate
        }
    }
    
}