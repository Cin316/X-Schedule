//
//  AnnouncementsWebViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 8/8/17.
//  Copyright © 2017 Nicholas Reichert. All rights reserved.
//

import UIKit
import WebKit

class AnnouncementsWebViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    
    func announcementsURL() -> String {
        return "https://www.stxavier.org/uploaded/announcements_x_schedule/current_announcements.pdf"
    }
    
    override func loadView() {
        // Set up the webView with default properties
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        
        // Set the child view of this view controller to the WKWebView
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string: announcementsURL())
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

}
