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
    
    override func onBackButtonPress(sender: AnyObject) {
        super.onBackButtonPress(sender)
        pageController().flipPageInDirection(UIPageViewControllerNavigationDirection.Reverse, withDate: scheduleDate)
    }
    override func onForwardButtonPress(sender: AnyObject) {
        super.onForwardButtonPress(sender)
        pageController().flipPageInDirection(UIPageViewControllerNavigationDirection.Forward, withDate: scheduleDate)
    }
    override func onTodayButtonPress(sender: AnyObject) {
        var previousDate: NSDate = scheduleDate
        super.onTodayButtonPress(sender)
        //Find which direction to flip in.
        switch (previousDate.compare(scheduleDate)) {
            case .OrderedAscending:
                pageController().flipPageInDirection(UIPageViewControllerNavigationDirection.Forward, withDate: scheduleDate)
            case .OrderedDescending:
                pageController().flipPageInDirection(UIPageViewControllerNavigationDirection.Reverse, withDate: scheduleDate)
            case .OrderedSame:
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
        controller = self.childViewControllers.first as! DataPageViewController
        
        return controller
    }
    
}
