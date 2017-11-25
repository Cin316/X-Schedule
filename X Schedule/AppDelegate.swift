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
    
    var applicationHasBeenActive: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        XLogger.redirectLogToFile()
        NSLog("[AppDelegate] Entering application didFinishLaunchingWithOptions")
        setUpTabBarDelegate()
        
        UnusualScheduleNotificationManager.requestAuthorizationForNotifications()
        UnusualScheduleNotificationManager.setUpBackgroundFetch()
        UnusualScheduleNotificationManager.loadScheduleTitles()
        
        return true
    }
    private func setUpTabBarDelegate() {
        //Allow delegate to control tab bar.
        if let tabBar = self.window?.rootViewController as? UITabBarController {
            tabBarDelegate = MainTabBarDelegate()
            tabBar.delegate = tabBarDelegate
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NSLog("[AppDelegate] Entering applicationDidBecomeActive")
        possiblyRefreshCache()
    }
    // The first time that the application enters the foreground, refresh the schedule cache.
    func possiblyRefreshCache() {
        NSLog("[AppDelegate] Possibly refreshing the cache...")
        if (!applicationHasBeenActive) {
            NSLog("[AppDelegate] Will be refreshing the cache.")
            applicationHasBeenActive = true
            CacheManager.refreshCache()
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        NSLog("[AppDelegate] Entering applicationWillEnterForeground")
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
        NSLog("[AppDelegate] Entering application performFetchWithCompletionHandler")
        UnusualScheduleNotificationManager.backgroundAppRefresh(completionHandler)
    }

}
