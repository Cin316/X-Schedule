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
    
    private var licensePath = Bundle.main.path(forResource: "LICENSE", ofType: "txt")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLegalText()
    }
    func loadLegalText() {
        if let path = licensePath {
            let licenseText = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
            if let license = licenseText {
                mainTextView.text = license
            }
        }
    }

}
