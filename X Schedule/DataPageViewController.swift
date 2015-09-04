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
        var initialContainerController = self.storyboard!.instantiateViewControllerWithIdentifier(DataPageViewControllerDataSource.scheduleIdentifier) as! SchedulePageViewController
        self.setViewControllers([initialContainerController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: {(bool: Bool) in})
    }
    
    func flipPageInDirection(direction: UIPageViewControllerNavigationDirection, withDate date: NSDate) {
        //Makes a new, blank ScheduleTableController.
        var newContainerController: SchedulePageViewController = self.storyboard!.instantiateViewControllerWithIdentifier(DataPageViewControllerDataSource.scheduleIdentifier) as! SchedulePageViewController
        
        //Populate table with schedule content.
        XScheduleManager.getScheduleForDate(date,
            completionHandler: {(schedule: Schedule) in
                newContainerController.schedule = schedule
            },
            errorHandler: {(errorText: String) in
                self.getDataController().handleError(errorText)
            }
        )
        
        //Disable swiping during the animation.
        self.view.userInteractionEnabled = false
        
        //Display the new table with correct animation.
        self.setViewControllers([newContainerController], direction: direction, animated: true, completion: {(bool: Bool) in
            //Reenable swiping when animation is finished.
            self.view.userInteractionEnabled = true
        })
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
        var containerController: SchedulePageViewController = pageViewController.storyboard!.instantiateViewControllerWithIdentifier(DataPageViewControllerDataSource.scheduleIdentifier) as! SchedulePageViewController
        
        //Find the right date to be put in the table.
        var date: NSDate = dateForNextSchedule(viewController as! SchedulePageViewController, direction: direction)
        
        //Populate table with schedule content.
        XScheduleManager.getScheduleForDate(date,
            completionHandler: {(schedule: Schedule) in
                containerController.schedule = schedule
            },
            errorHandler: {(errorText: String) in
                var parentViewController: DataPageViewController = pageViewController as! DataPageViewController
                parentViewController.getDataController().handleError(errorText)
            }
        )
        
        return containerController
    }
    
    private func dateForNextSchedule(previousController: SchedulePageViewController, direction: UIPageViewControllerNavigationDirection) -> NSDate {
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
            var newViewController: SchedulePageViewController = pageViewController.viewControllers.first! as! SchedulePageViewController
            var newDate: NSDate = newViewController.schedule.date
            var parentViewController: DataPageViewController = pageViewController as! DataPageViewController
            parentViewController.getDataController().scheduleDate = newDate
        }
    }
    
}
