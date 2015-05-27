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
    
    private var donorsPath: String = NSBundle.mainBundle().pathForResource("donors", ofType: "txt")!
    private var editedDonorsPath: String = DonorsViewController.documentsDirectory().stringByAppendingPathComponent("editedDonors.txt")
    
    private var onlineDonorsURL: NSURL = NSURL(string: "http://raw.githubusercontent.com/Cin316/X-Schedule/develop/donors.txt")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayStoredFiles()
        updateStoredDonors()
    }
    private func displayStoredFiles() {
        //Read path from editedDonors.txt and display it if it exists.
        if (fileExists(editedDonorsPath)) {
            displayContentsOfFile(editedDonorsPath)
        } else {
            //If it doesn't, read donors.txt in the read-only app bundle and display it.
            displayContentsOfFile(donorsPath)
        }
    }
    private func updateStoredDonors() {
        //Attempt to download donors from website and update saved donors.txt.
        var session = downloadSession()
        
        var postSession = session.downloadTaskWithURL(onlineDonorsURL, completionHandler:
            { (url: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
                //If the request was successful...
                if let realURL = url {
                    //Get text of download.
                    var fileText = String(contentsOfURL: url, encoding: NSUTF8StringEncoding, error: nil)
                    if let realFileText = fileText {
                        //Save to editedDonors.txt.
                        self.saveEditedDonorsText(realFileText)
                        //Display in GUI
                        dispatch_async(dispatch_get_main_queue()) {
                            self.displayStoredFiles()
                        }
                    }
                }
            }
        )
        
        postSession.resume()
    }
    private func downloadSession() -> NSURLSession {
        var config: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session: NSURLSession = NSURLSession(configuration: config)
        
        return session
    }
    private func saveEditedDonorsText(downloadedText: String) {
        downloadedText.writeToFile(self.editedDonorsPath, atomically: false, encoding: NSUTF8StringEncoding, error: nil)
    }
    private func displayDonors(donorListText: String?) {
        //Displays the list of donors in a center aligned text view.
        if let donorList = donorListText {
            mainTextView.text = donorList
        }
    }
    private func displayContentsOfFile(filePath: String) {
        var fileContents: String? = String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: nil)
        displayDonors(fileContents)
    }
    private class func documentsDirectory() -> String {
        let directories: [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as! [String]
        let documentsDirectory: String =  directories[0]
        
        return documentsDirectory
    }
    private func fileExists(filePath: String) -> Bool {
        var manager: NSFileManager = NSFileManager.defaultManager()
        var exists: Bool = manager.fileExistsAtPath(filePath)
        
        return exists
    }
    
}