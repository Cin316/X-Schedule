//
//  ScheduleSwitcherViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 3/16/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit

class ScheduleSwitcherViewController: UINavigationController {
    
    var currentOrientation: UIDeviceOrientation = UIDevice.currentDevice().orientation;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Correct tab bar title.
        self.title = "Schedule" // TODO Fix tab bar title.
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
        // TODO Add check to avoid creating a new view every time.
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) { //If on iPhone...
            //Do nothing, because there is only one orientation.
            self.performSegueWithIdentifier("displayScheduleiPhone", sender: self)
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) { //If on iPad...
            //Check orientation.
            if (UIDeviceOrientationIsLandscape(currentOrientation)) { //If orientation is landscape...
                // TODO Add this view to the storyboard.
                self.performSegueWithIdentifier("displayScheduleiPadLandscape", sender: self)
            } else if (UIDeviceOrientationIsPortrait(currentOrientation)) { //If orientation is portrait...
                self.performSegueWithIdentifier("displayScheduleiPadPortrait", sender: self)
            }
        }
    }
}
