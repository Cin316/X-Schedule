//
//  MainTabBarDelegate.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 5/3/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit
import XScheduleKit

class MainTabBarDelegate: NSObject, UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        var oldViewController: UIViewController = currentlySelectedViewController(tabBarController)
        //If the schedule tab is selected again while it's already selected.
        if (oldViewController.tabBarItem.tag == 401 && viewController.tabBarItem.tag == 401) {
            if let switcher = viewController as? ScheduleSwitcherViewController {
                var dataView: ScheduleViewController = getScheduleViewController(switcher)!
                
                dataView.scheduleDate = NSDate()
            }
        }
        return true
    }
    private func currentlySelectedViewController(tabBarController: UITabBarController) -> UIViewController {
        var selectedItem: AnyObject = tabBarController.viewControllers![tabBarController.selectedIndex]
        var viewController: UIViewController = selectedItem as! UIViewController
        
        return viewController
    }
    private func getScheduleViewController(switcher: ScheduleSwitcherViewController) -> ScheduleViewController? {
        var returnController: ScheduleViewController?
        if let currentView = switcher.currentView {
            if let scheduleView = currentView as? ScheduleViewController {
                returnController = scheduleView
            }
        }
        return returnController
    }
    
}
