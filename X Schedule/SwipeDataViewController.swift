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
    
    override func pressBackButton() {
        super.pressBackButton()
        pageController().flipPageInDirection(UIPageViewControllerNavigationDirection.Reverse, withDate: scheduleDate)
    }
    override func pressForwardButton() {
        super.pressForwardButton()
        pageController().flipPageInDirection(UIPageViewControllerNavigationDirection.Forward, withDate: scheduleDate)
    }
    
    override func tableController() -> ScheduleTableController? {
        return nil
    }
    
    private func pageController() -> DataPageViewController {
        var controller: DataPageViewController
        controller = self.childViewControllers.first as! DataPageViewController
        
        return controller
    }
    
}
