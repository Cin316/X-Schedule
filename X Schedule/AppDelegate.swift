//
//  AppDelegate.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/13/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //Allow self to control tab bar.
        if let tabBar = self.window?.rootViewController as? UITabBarController {
            tabBar.delegate = self
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // TODO Refactor and clean up this code.
        //Set date to today on app reopen.
        
        var rootController = self.window!.rootViewController!
        var tabBarController: UITabBarController = rootController as! UITabBarController
        
        for controller in tabBarController.viewControllers! {
            var viewController = controller as! UIViewController
            if (viewController.tabBarItem.tag == 401) {
                if let switcher = viewController as? ScheduleSwitcherViewController {
                    if let currentView = switcher.currentView {
                        //Set schedule date to today.
                        if let dataView = currentView as? DataViewController {
                            dataView.scheduleDate = NSDate()
                            dataView.refreshSchedule()
                        }  else if let dataView = currentView as? WeekDataViewController {
                            dataView.scheduleDate = NSDate()
                            dataView.refreshSchedule()
                        }
                    }
                }
            }
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        var oldViewController: UIViewController = tabBarController.viewControllers![tabBarController.selectedIndex] as! UIViewController
        //If the schedule tab is selected again while it's already selected.
        if (oldViewController.tabBarItem.tag == 401 && viewController.tabBarItem.tag == 401) {
            if let switcher = viewController as? ScheduleSwitcherViewController {
                if let currentView = switcher.currentView {
                    //Set schedule date to today.
                    if let dataView = currentView as? DataViewController {
                        dataView.scheduleDate = NSDate()
                        dataView.refreshSchedule()
                    }  else if let dataView = currentView as? WeekDataViewController {
                        dataView.scheduleDate = NSDate()
                        dataView.refreshSchedule()
                    }
                }
            }
        }
        return true
    }

}

