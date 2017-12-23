//
//  XLogger.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 11/5/17.
//  Copyright © 2017 Nicholas Reichert.
//

import Foundation

open class XLogger {
    
    open class func redirectLogToFile() {
        let docDirectory: NSString = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
        let logpath = docDirectory.appendingPathComponent("XScheduleLog.txt")
        freopen(logpath.cString(using: String.Encoding.ascii)!, "a+", stderr)
    }
    
}
