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
    var pageDataSource = DataPageViewControllerDataSource()
    
    override func viewDidLoad() {
        self.dataSource = pageDataSource
        var initialController = pageDataSource.pageChanged(nil, pageViewController: self, currentController: nil)!
        self.setViewControllers([initialController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: {(bool: Bool) in })
    }
}

class DataPageViewControllerDataSource: NSObject, UIPageViewControllerDataSource {
    
    private static let scheduleIdentifier = "ColoredScheduleTableViewController"
    
    enum Direction {
        case Before
        case After
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return pageChanged(.Before, pageViewController: pageViewController, currentController: viewController)
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return pageChanged(.After, pageViewController: pageViewController, currentController: viewController)
    }
    
    private func pageChanged(direction: Direction?, pageViewController: UIPageViewController, currentController: UIViewController?) -> UIViewController? {
        var date: NSDate = dateForViews(direction, currentController: currentController)
        var outputController: ScheduleTableController? = pageViewController.storyboard!.instantiateViewControllerWithIdentifier(DataPageViewControllerDataSource.scheduleIdentifier) as! ScheduleTableController?
        return outputController
    }
    private func dateForViews(direction: Direction?, currentController: UIViewController?) -> NSDate {
        var date: NSDate
        if let tableController = currentController as? ScheduleTableController {
            var timeCoeff: Double
            switch direction! {
            case .Before:
                timeCoeff = -1.0
            case .After:
                timeCoeff = 1.0
            }
            date = tableController.schedule.date.dateByAddingTimeInterval(timeCoeff*24*60*60)
        } else {
            date = NSDate()
        }
        
        return date
    }
    
}