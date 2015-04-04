//
//  ScheduleSwitcherViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 3/16/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit

class ScheduleSwitcherViewController: UINavigationController {
    
    var currentOrientation: UIDeviceOrientation = UIDevice.currentDevice().orientation
    var scheduleDate: NSDate = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Correct tab bar title.
        self.title = "Schedule"
        self.tabBarController!.title = "Schedule"
        
        //Get current orientation and store it.
        currentOrientation = UIDevice.currentDevice().orientation
        switchToOrientationView()
        
        //Register orientation change listener.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationDidChangeNotification", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Correct tab bar title.
        self.title = "Schedule"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deviceOrientationDidChangeNotification() {
        currentOrientation = UIDevice.currentDevice().orientation
        switchToOrientationView()
    }
    
    func switchToOrientationView() {
        //Take date from current view controller and store it.
        if let top = self.topViewController {
            if let topData = top as? DataViewController {
                self.scheduleDate = topData.scheduleDate
            }
        }
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) { //If on iPhone...
            //Check if there is a view already.
            if (self.topViewController != nil) {
                //Do nothing, because there is only one orientation.
            } else {
                //Add a new iPhone view controller.
                self.performSegueWithIdentifier("displayScheduleiPhone", sender: self)
            }
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) { //If on iPad...
            //Check orientation.
            if (UIDeviceOrientationIsLandscape(currentOrientation)) { //If orientation is landscape...
                self.performSegueWithIdentifier("displayScheduleiPadLandscape", sender: self)
            } else if (UIDeviceOrientationIsPortrait(currentOrientation)) { //If orientation is portrait...
                self.performSegueWithIdentifier("displayScheduleiPadPortrait", sender: self)
            }
        }
        
        //Store date in new view controller if necessary.
        if let top = self.topViewController {
            if let topData = top as? DataViewController {
                topData.scheduleDate = self.scheduleDate
            }
        }
    }
}

class NoAnimationSegue: UIStoryboardSegue {
    override func perform() {
        let source = sourceViewController as UINavigationController //This will crash if not used with a UINaviagtionController.
        let destination = destinationViewController as UIViewController
        //Transition with no animation.  Sets new view as root view controller.
        source.setViewControllers([destination], animated: false)
    }
    
}