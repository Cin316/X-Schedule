//
//  XScheduleDownloader.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/17/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

public class XScheduleDownloader: ScheduleDownloader {
    
    private static var scheduleCalenderID: String = "27"
    private static var scheduleURL: NSURL = NSURL(string: "http://www.stxavier.org/cf_calendar/export.cfm")!
    
    public override class func downloadSchedule(date: NSDate, completionHandler: String -> Void, errorHandler: String -> Void) -> NSURLSessionTask {
        //Download today's schedule from the St. X website.
    
        //Create objects for network request.
        var postData: NSData = requestDataForDate(date)
        var request: NSURLRequest = scheduleWebRequest()
        var session: NSURLSession = scheduleSession()
        
        //Create NSURLSessionUploadTask out of desired objects.
        var postSession: NSURLSessionTask = session.uploadTaskWithRequest(request, fromData: postData, completionHandler:
            { ( data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                //Convert output to a string.
                var output = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
                
                if (error == nil) {
                    //Call completion handler with string.
                    completionHandler(output)
                } else { // If there is an error...
                    if ( self.errorShouldBeHandled(error) ) {
                        errorHandler(error.localizedDescription)
                    }
                }
            }
        )
        //Start POST request.
        postSession.resume()
        
        return postSession
    }
    private class func scheduleWebRequest() -> NSURLRequest {
        //Create a new NSURLRequest with the correct parameters to download schedule from St. X Website.
        var request = NSMutableURLRequest(URL: scheduleURL)
        request.HTTPMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    private class func scheduleSession() -> NSURLSession {
        //Create a new NSURLSession with default settings.
        var config = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: config)
        
        return session
    }
    private class func requestDataForDate(date: NSDate) -> NSData {
        //Create NSData object to send in body of POST request.
        let escapedDate = uploadStringForDate(date)
        var postString: NSString = "export_format=xml&start=\(escapedDate)&end=\(escapedDate)&calendarId=\(scheduleCalenderID)"
        var postData: NSData = postString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        return postData
    }
    private class func uploadStringForDate(date: NSDate) -> String {
        //Returns a correctly formatted string to upload in as a POST parameter.
        var dateFormat: NSDateFormatter = NSDateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy"
        dateFormat.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let formattedDate: String = dateFormat.stringFromDate(date)
        let escapedDate: String = formattedDate.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
        return escapedDate
    }
    private class func errorShouldBeHandled(error: NSError) -> Bool {
        var ignoredError: Bool = false
        ignoredError = ignoredError || (error.domain==NSURLErrorDomain && error.code==NSURLErrorCancelled)
        
        return !ignoredError
    }
    
}
