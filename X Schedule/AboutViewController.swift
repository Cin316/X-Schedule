//
//  AboutViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 3/7/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit
import XScheduleKit

class AboutViewController: UITableViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    
    private var cellColor: UIColor = UIColor(red: (225.0/255.0), green: (238.0/255.0), blue: (254.0/255.0), alpha: 1.0)
    
    var versionNumber: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    var buildNumber: String = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayVersionNumber()
    }
    private func displayVersionNumber() {
        versionLabel.text = "\(versionNumber) (\(buildNumber))"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell: UITableViewCell? = tableView.cellForRow(at: indexPath)
        if let cell = selectedCell {
            if (cell.tag == 200) { //GitHub link
                openURL("https://github.com/Cin316/X-Schedule")
            } else if (cell.tag == 201) { //St. X link
                openURL("https://www.stxavier.org/")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    private func openURL(_ url: String) {
        let url: URL = URL(string: url)!
        UIApplication.shared.openURL(url)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //Fix background color on iPad.
        cell.backgroundColor = cellColor
    }
}
