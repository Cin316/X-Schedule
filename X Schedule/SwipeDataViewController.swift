//
//  SwipeDataViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 6/28/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit
import XScheduleKit

class SwipeDataViewController: DataViewController {
    
    @IBAction func onUIBackButtonPress(_ sender: Any) {
        super.onBackButtonPress(sender as AnyObject)
        pageController().flipPageInDirection(UIPageViewController.NavigationDirection.reverse, withDate: scheduleDate)
    }
    @IBAction func onUIForwardButtonPress(_ sender: Any) {
        super.onForwardButtonPress(sender as AnyObject)
        pageController().flipPageInDirection(UIPageViewController.NavigationDirection.forward, withDate: scheduleDate)
    }
    override func onTodayButtonPress(_ sender: Any) {
        let previousDate: Date = scheduleDate
        super.onTodayButtonPress(sender)
        //Find which direction to flip in.
        switch (previousDate.compare(scheduleDate)) {
            case .orderedAscending:
                pageController().flipPageInDirection(UIPageViewController.NavigationDirection.forward, withDate: scheduleDate)
            case .orderedDescending:
                pageController().flipPageInDirection(UIPageViewController.NavigationDirection.reverse, withDate: scheduleDate)
            case .orderedSame:
                break //Do nothing.
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onTodayButtonPress(self)
    }
    
    override func tableController() -> ScheduleTableController? {
        return nil
    }
    
    override func emptyUILabel() -> UILabel? {
        return nil
    }
    
    func pageController() -> DataPageViewController {
        var controller: DataPageViewController
        controller = self.children.first as! DataPageViewController
        
        return controller
    }
    
}
