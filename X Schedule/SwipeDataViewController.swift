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
    override func tableController() -> ScheduleTableController? {
        return pageController()?.currentTable
    }
    private func pageController() -> DataPageViewController? {
        return childViewControllers[0] as? DataPageViewController
    }
    @IBAction override func onBackButtonPress(sender: AnyObject) {
        pageController()?.changePage(UIPageViewControllerNavigationDirection.Reverse)
        super.onBackButtonPress(sender)
    }
    @IBAction override func onForwardButtonPress(sender: AnyObject) {
        pageController()?.changePage(UIPageViewControllerNavigationDirection.Forward)
        super.onForwardButtonPress(sender)
    }
    
}