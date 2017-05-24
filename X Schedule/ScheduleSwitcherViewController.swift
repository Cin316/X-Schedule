//
//  ScheduleSwitcherViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 3/16/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit
import XScheduleKit

class ScheduleSwitcherViewController: UINavigationController {

    var scheduleDate: Date = Date()
    var currentView: UIViewController? // Publically accessible property
    var oldOrientation: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchToOrientationView()
    }
    
    override func viewWillLayoutSubviews() {
        switchToOrientationView()
    }
    
    func switchToOrientationView() {
        loadScheduleDateIntoViewController(self.topViewController)
        performSegueBasedOnAspectRatio()
        storeScheduleDate()
        updateCurrentView()
    }
    private func performSegueBasedOnAspectRatio() {
        if (UIDevice.current.userInterfaceIdiom == .phone) { //If on iPhone...
            //Check if there is a view already.
            if (self.topViewController != nil) {
                //Do nothing, because there is only one orientation.
            } else {
                //Add a new iPhone view controller.
                self.performSegue(withIdentifier: "displayScheduleiPhone", sender: self)
            }
        } else if (UIDevice.current.userInterfaceIdiom == .pad) { //If on iPad...
            // If the current orientation is different from the old orientation, preform a switch.
            let newOrientation = getNewOrientation()
            if (oldOrientation != newOrientation) {
                self.performSegue(withIdentifier: newOrientation, sender: self)
                oldOrientation = newOrientation
            }
        }
    }
    private func getNewOrientation() -> String {
        // Determine what the current orientation should be.
        var newOrientation: String = ""
        if (aspectRatio() < 0.85) { // 0.85 is the cutoff between portrait and landscape.
            newOrientation = "displayScheduleiPadPortrait"
        } else {
            newOrientation = "displayScheduleiPadLandscape"
        }
        
        return newOrientation
    }
    private func aspectRatio() -> CGFloat {
        let frame = UIApplication.shared.delegate!.window!!.frame
        let aspectRatio: CGFloat = frame.width / frame.height
        
        return aspectRatio
    }
    private func loadScheduleDateIntoViewController(_ viewController: UIViewController?) {
        //Take date from current view controller and store it.
        if let top = viewController {
            if let topData = top as? ScheduleViewController {
                self.scheduleDate = topData.scheduleDate
            }
        }
    }
    private func storeScheduleDate() {
        //Store date in new view controller if necessary.
        if let top = self.topViewController {
            if let topData = top as? ScheduleViewController {
                topData.scheduleDate = self.scheduleDate
            }
        }
    }
    private func updateCurrentView() {
        //Store the value of the current view.
        if let top = self.topViewController {
            currentView = top
        }
    }
    
}

class NoAnimationSegue: UIStoryboardSegue {
    override func perform() {
        if let source = source as? UINavigationController {
            //Transition with no animation.  Sets new view as root view controller.
            source.setViewControllers([destination], animated: false)
        }
    }
    
}
