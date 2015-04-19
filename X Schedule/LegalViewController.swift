//
//  LegalViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 3/5/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit

class LegalViewController: UIViewController {

    @IBOutlet weak var mainTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var path = NSBundle.mainBundle().pathForResource("LICENSE", ofType: "txt")
        var licenseText = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
        
        if let license = licenseText {
            mainTextView.text = license
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

