//
//  ScheduleDownloader.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/17/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

public class ScheduleDownloader {
    
    public class func downloadSchedule(date: NSDate, completionHandler: String -> Void) -> NSURLSessionTask {
        // Download today's schedule from the St. X website.
        // Setup for request.
        var url = NSURL(string:"http://www.stxavier.org/cf_calendar/export.cfm")!
        var config = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: config)
        
        var request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        //Get today's date and format it correctly for request.
        var downloadDate = date
        var dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy"
        let formattedDate = dateFormat.stringFromDate(downloadDate)
        let escapedDate = formattedDate.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
        //Create NSData object to send in body of POST request.
        var postData = "export_format=xml&start=\(escapedDate)&end=\(escapedDate)&calendarId=27".dataUsingEncoding(NSUTF8StringEncoding)
        
        //Create NSURLSessionUploadTask out of desired settings.
        var postSession = session.uploadTaskWithRequest(request, fromData: postData, completionHandler:
            { ( data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                //Convert output to a string.
                var output = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
                //Call completion handler with string.
                completionHandler(output)
            }
        )
        //Start POST request.
        postSession.resume()
        
        return postSession
    }
    
    public class func downloadSchedule(completionHandler: String -> Void) -> NSURLSessionTask {
        var currentDate = NSDate()
        return downloadSchedule(currentDate, completionHandler: completionHandler)
    }
    
}