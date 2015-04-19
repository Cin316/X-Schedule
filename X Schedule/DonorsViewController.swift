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
        
        var donorsPath = NSBundle.mainBundle().pathForResource("donors", ofType: "txt")!
        
        //Attempt to download donors from website and update saved donors.txt.
        var url = NSURL(string: "http://raw.githubusercontent.com/Cin316/X-Schedule/develop/donors.txt")!
        var config = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: config)
        var request = NSMutableURLRequest(URL: url)
        
        var postSession = session.downloadTaskWithURL(url, completionHandler:
            { (url: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
                //If the request was successful...
                if let realURL = url {
                    //Get text of download.
                    var fileText = String(contentsOfURL: url, encoding: NSUTF8StringEncoding, error: nil)
                    if let realFileText = fileText {
                        //Save to donors.txt.
                        realFileText.writeToFile(donorsPath, atomically: false, encoding: NSUTF8StringEncoding, error: nil)
                    }
                }
            }
        )
        
        postSession.resume()
        
        //Load and display donors.txt.
        var donorListText = String(contentsOfFile: donorsPath, encoding: NSUTF8StringEncoding, error: nil)
        
        if let donorList = donorListText {
            mainTextView.text = donorList
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}