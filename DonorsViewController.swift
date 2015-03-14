//
//  DonorsViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 3/13/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit

class DonorsViewController: UIViewController {
    
    @IBOutlet weak var mainTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var path = NSBundle.mainBundle().pathForResource("donors", ofType: "txt")
        var donorListText = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
        
        if let donorList = donorListText {
            mainTextView.text = donorList
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}