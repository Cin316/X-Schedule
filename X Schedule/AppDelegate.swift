//
//  AppDelegate.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/13/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit
import XScheduleKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tabBarDelegate: MainTabBarDelegate?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setUpTabBarDelegate()
        
        CacheManager.buildCache()
        
        return true
    }
    private func setUpTabBarDelegate() {
        //Allow delegate to control tab bar.
        if let tabBar = self.window?.rootViewController as? UITabBarController {
            tabBarDelegate = MainTabBarDelegate()
            tabBar.delegate = tabBarDelegate
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        refreshSchedule()
    }
    
    func refreshSchedule() {
        let scheduleViewController: ScheduleViewController = getScheduleViewController()!
        scheduleViewController.refreshSchedule()
        
        if let pageView = scheduleViewController as? SwipeDataViewController {
            pageView.pageController().flipPageInDirection(UIPageViewControllerNavigationDirection.forward, withDate: pageView.scheduleDate)
        }
    }
    private func getScheduleSwitcherViewController() -> ScheduleSwitcherViewController? {
        var returnController: ScheduleSwitcherViewController?
        let tabBarController: UITabBarController = self.window!.rootViewController! as! UITabBarController
        for controller in tabBarController.viewControllers! {
            let viewController = controller 
            if let switcher = viewController as? ScheduleSwitcherViewController {
                returnController = switcher
            }
        }
        return returnController
    }
    private func getScheduleViewController() -> ScheduleViewController? {
        let switcher = getScheduleSwitcherViewController()!
        var returnController: ScheduleViewController?
        if let currentView = switcher.currentView {
            if let scheduleView = currentView as? ScheduleViewController {
                returnController = scheduleView
            }
        }
        return returnController
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Add code here for background app refresh.
        // Call the completion handler when I'm done.
        // TODO Change ScheduleManager implementation to allow specifying a download method.
        //XScheduleManager.getScheduleF, completionHandler: <#T##(Schedule) -> Void#>, errorHandler: <#T##(String) -> Void#>, method: &<#T##DownloadMethod#>
    }

}
