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
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let oldViewController: UIViewController = currentlySelectedViewController(tabBarController)
        //If the schedule tab is selected again while it's already selected.
        if (oldViewController.tabBarItem.tag == 401 && viewController.tabBarItem.tag == 401) {
            if let switcher = viewController as? ScheduleSwitcherViewController {
                let dataView: ScheduleViewController = getScheduleViewController(switcher)!
                
                dataView.onTodayButtonPress(self)
            }
        }
        //Refresh schedule if switching to the tab.
        else if (viewController.tabBarItem.tag == 401) {
            let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            app.refreshSchedule()
        }
        return true
    }
    private func currentlySelectedViewController(_ tabBarController: UITabBarController) -> UIViewController {
        let selectedItem: AnyObject = tabBarController.viewControllers![tabBarController.selectedIndex]
        let viewController: UIViewController = selectedItem as! UIViewController
        
        return viewController
    }
    private func getScheduleViewController(_ switcher: ScheduleSwitcherViewController) -> ScheduleViewController? {
        var returnController: ScheduleViewController?
        if let currentView = switcher.currentView {
            if let scheduleView = currentView as? ScheduleViewController {
                returnController = scheduleView
            }
        }
        return returnController
    }
    
}
