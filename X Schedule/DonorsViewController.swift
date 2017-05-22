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
    
    private var donorsPath: String = Bundle.main.path(forResource: "donors", ofType: "txt")!
    private var editedDonorsPath: String = URL(fileURLWithPath: DonorsViewController.documentsDirectory()).appendingPathComponent("editedDonors.txt").relativePath
    
    private var onlineDonorsURL: URL = URL(string: "https://raw.githubusercontent.com/Cin316/X-Schedule/develop/donors.txt")!
    
    override func viewDidAppear(_ animated: Bool) {
        mainTextView.flashScrollIndicators()
    }
    
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
        let session = downloadSession()
        
        let postSession = session.downloadTask(with: onlineDonorsURL, completionHandler:
            { (url: URL?, response: URLResponse?, error: Error?) -> Void in
                //If the request was successful...
                if let realURL = url {
                    //Get text of download.
                    let fileText = try? String(contentsOf: realURL, encoding: String.Encoding.utf8)
                    if let realFileText = fileText {
                        //Save to editedDonors.txt.
                        self.saveEditedDonorsText(realFileText)
                        //Display in GUI
                        DispatchQueue.main.async {
                            self.displayStoredFiles()
                        }
                    }
                }
            }
        )
        
        postSession.resume()
    }
    private func downloadSession() -> URLSession {
        let config: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: config)
        
        return session
    }
    private func saveEditedDonorsText(_ downloadedText: String) {
        do {
            try downloadedText.write(toFile: self.editedDonorsPath, atomically: false, encoding: String.Encoding.utf8)
        } catch _ {
        }
    }
    private func displayDonors(_ donorListText: String?) {
        //Displays the list of donors in a center aligned text view.
        if let donorList = donorListText {
            mainTextView.text = donorList
        }
    }
    private func displayContentsOfFile(_ filePath: String) {
        let fileContents: String? = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        displayDonors(fileContents)
    }
    private class func documentsDirectory() -> String {
        let directories: [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true) 
        let documentsDirectory: String =  directories[0]
        
        return documentsDirectory
    }
    private func fileExists(_ filePath: String) -> Bool {
        let manager: FileManager = FileManager.default
        let exists: Bool = manager.fileExists(atPath: filePath)
        
        return exists
    }
    
}
