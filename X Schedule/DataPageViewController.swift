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
    var pageDataSource: DataPageViewControllerDataSource?
    var currentTable: ScheduleTableController?
    
    override func viewDidLoad() {
        pageDataSource = DataPageViewControllerDataSource(viewController: self)
        self.dataSource = pageDataSource
        var initialController = pageDataSource!.pageChanged(nil, pageViewController: self, currentController: nil)!
        self.setViewControllers([initialController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: {(bool: Bool) in })
    }
    
    func changePage(direction: UIPageViewControllerNavigationDirection) {
        var initialController = pageDataSource!.pageChanged(nil, pageViewController: self, currentController: currentTable)!
        self.setViewControllers([initialController], direction: direction, animated: true, completion: {(bool: Bool) in })
    }
    
    func getDataController() -> DataViewController {
        return self.parentViewController as! DataViewController
    }
}

class DataPageViewControllerDataSource: NSObject, UIPageViewControllerDataSource {
    
    private static let scheduleIdentifier = "ColoredScheduleTableViewController"
    weak var parentController: DataPageViewController?
    
    enum Direction {
        case Before
        case After
    }
    
    init(viewController: DataPageViewController) {
        parentController = viewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var outputController = pageChanged(.Before, pageViewController: pageViewController, currentController: viewController)
        self.parentController?.currentTable = outputController as? ScheduleTableController
        self.parentController?.getDataController().onBackButtonPress(self)
        return outputController
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var outputController = pageChanged(.Before, pageViewController: pageViewController, currentController: viewController)
        self.parentController?.currentTable = outputController as? ScheduleTableController
        self.parentController?.getDataController().onForwardButtonPress(self)
        return outputController
    }
    
    private func pageChanged(direction: Direction?, pageViewController: UIPageViewController, currentController: UIViewController?) -> UIViewController? {
        var outputController: ScheduleTableController? = pageViewController.storyboard!.instantiateViewControllerWithIdentifier(DataPageViewControllerDataSource.scheduleIdentifier) as! ScheduleTableController?
        return outputController
    }
    
}