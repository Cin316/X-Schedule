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
        let initialContainerController = self.storyboard!.instantiateViewController(withIdentifier: DataPageViewControllerDataSource.scheduleIdentifier) as! SchedulePageViewController
        self.setViewControllers([initialContainerController], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: {(bool: Bool) in})
    }
    
    func flipPageInDirection(_ direction: UIPageViewController.NavigationDirection, withDate date: Date) {
        //Makes a new, blank ScheduleTableController.
        let newContainerController: SchedulePageViewController = self.storyboard!.instantiateViewController(withIdentifier: DataPageViewControllerDataSource.scheduleIdentifier) as! SchedulePageViewController
        
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
        self.view.isUserInteractionEnabled = false
        
        //Display the new table with correct animation.
        self.setViewControllers([newContainerController], direction: direction, animated: true, completion: {(bool: Bool) in
            //Reenable swiping when animation is finished.
            self.view.isUserInteractionEnabled = true
        })
    }
    
    func getDataController() -> DataViewController {
        return self.parent as! DataViewController
    }
}

class DataPageViewControllerDataSource: NSObject, UIPageViewControllerDataSource {
    
    fileprivate static let scheduleIdentifier = "ColoredScheduleTableViewController"
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return getNewViewController(pageViewController, viewController: viewController, direction: UIPageViewController.NavigationDirection.reverse)
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return getNewViewController(pageViewController, viewController: viewController, direction: UIPageViewController.NavigationDirection.forward)
    }
    
    func getNewViewController(_ pageViewController: UIPageViewController, viewController: UIViewController, direction: UIPageViewController.NavigationDirection) -> UIViewController? {
        //Makes a new, blank ScheduleTableController.
        let containerController: SchedulePageViewController = pageViewController.storyboard!.instantiateViewController(withIdentifier: DataPageViewControllerDataSource.scheduleIdentifier) as! SchedulePageViewController
        
        //Find the right date to be put in the table.
        let date: Date = dateForNextSchedule(viewController as! SchedulePageViewController, direction: direction)
        
        //Populate table with schedule content.
        XScheduleManager.getScheduleForDate(date,
            completionHandler: {(schedule: Schedule) in
                containerController.schedule = schedule
            },
            errorHandler: {(errorText: String) in
                let parentViewController: DataPageViewController = pageViewController as! DataPageViewController
                parentViewController.getDataController().handleError(errorText)
            }
        )
        
        return containerController
    }
    
    private func dateForNextSchedule(_ previousController: SchedulePageViewController, direction: UIPageViewController.NavigationDirection) -> Date {
        let oldDate: Date = previousController.schedule.date
        let timeCoeff: Double = (direction == UIPageViewController.NavigationDirection.forward) ? 1.0 : -1.0
        let newDate: Date = oldDate.addingTimeInterval(timeCoeff*60*60*24)
        
        return newDate
    }
    
}

class DataPageViewControllerDelegate: NSObject, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        //When the user finishes turning a page with a gesture...
        if (completed) {
            //Update the DataViewController's date to match that of the new page.
            let newViewController: SchedulePageViewController = pageViewController.viewControllers!.first! as! SchedulePageViewController
            let newDate: Date = newViewController.schedule.date
            let parentViewController: DataPageViewController = pageViewController as! DataPageViewController
            parentViewController.getDataController().scheduleDate = newDate
        }
    }
    
}
