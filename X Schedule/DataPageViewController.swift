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
        pageDataSource = DataPageViewControllerDataSource()
        self.dataSource = pageDataSource
        
        pageDelegate = DataPageViewControllerDelegate()
        self.delegate = pageDelegate
        
        //Display a blank table.  This fixes a crash where this controller has no table.
        var initialController = self.storyboard!.instantiateViewControllerWithIdentifier(DataPageViewControllerDataSource.scheduleIdentifier) as! ScheduleTableController
        self.setViewControllers([initialController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: {(bool: Bool) in })
    }
    
    func flipPageInDirection(direction: UIPageViewControllerNavigationDirection, withDate date: NSDate) {
        //Makes a new, blank ScheduleTableController.
        var newController: ScheduleTableController = self.storyboard!.instantiateViewControllerWithIdentifier(DataPageViewControllerDataSource.scheduleIdentifier) as! ScheduleTableController
        
        //Populate table with schedule content.
        XScheduleManager.getScheduleForDate(date,
            completionHandler: {(schedule: Schedule) in
                newController.schedule = schedule
            },
            errorHandler: {(errorText: String) in
                //println("\(errorText)")
                // TODO Handle error.
            }
        )
        
        //Display the new table with correct animation.
        self.setViewControllers([newController], direction: direction, animated: true, completion: {(bool: Bool) in })
    }
    
    func getDataController() -> DataViewController {
        return self.parentViewController as! DataViewController
    }
}

class DataPageViewControllerDataSource: NSObject, UIPageViewControllerDataSource {
    
    private static let scheduleIdentifier = "ColoredScheduleTableViewController"
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return getNewViewController(pageViewController, viewController: viewController, direction: UIPageViewControllerNavigationDirection.Reverse)
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return getNewViewController(pageViewController, viewController: viewController, direction: UIPageViewControllerNavigationDirection.Forward)
    }
    
    func getNewViewController(pageViewController: UIPageViewController, viewController: UIViewController, direction: UIPageViewControllerNavigationDirection) -> UIViewController? {
        //Makes a new, blank ScheduleTableController.
        var outputController: ScheduleTableController = pageViewController.storyboard!.instantiateViewControllerWithIdentifier(DataPageViewControllerDataSource.scheduleIdentifier) as! ScheduleTableController
        
        //Find the right date to be put in the table.
        var date: NSDate = dateForNextSchedule(viewController as! ScheduleTableController, direction: direction)
        
        //Populate table with schedule content.
        XScheduleManager.getScheduleForDate(date,
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
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        //When the user finishes turning a page with a gesture...
        if (completed) {
            //Update the DataViewController's date to match that of the new page.
            var newViewController: ScheduleTableController = pageViewController.viewControllers.first! as! ScheduleTableController
            var newDate: NSDate = newViewController.schedule.date
            var parentViewController: DataPageViewController = pageViewController as! DataPageViewController
            parentViewController.getDataController().scheduleDate = newDate
        }
    }
    
}