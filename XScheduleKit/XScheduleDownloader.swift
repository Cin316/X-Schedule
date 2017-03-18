//
//  XScheduleDownloader.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/17/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

open class XScheduleDownloader: ScheduleDownloader {
    
    private static var scheduleCalenderID: String = "27"
    private static var scheduleURL: URL = URL(string: "https://www.stxavier.org/cf_calendar/export.cfm")!
    
    open override class func downloadSchedule(_ date: Date, completionHandler: @escaping (String) -> Void, errorHandler: @escaping (String) -> Void) -> URLSessionTask {
        //Download today's schedule from the St. X website.
    
        //Create objects for network request.
        let postData: Data = requestDataForDate(date)
        let request: URLRequest = scheduleWebRequest()
        let session: URLSession = scheduleSession()
        
        //Create NSURLSessionUploadTask out of desired objects.
        let postSession: URLSessionTask = session.uploadTask(with: request, from: postData, completionHandler:
            { ( data: Data?, response: URLResponse?, error: Error?) -> Void in
                //Convert output to a string.
                var output: String
                if (data != nil) {
                    output = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as! String
                } else {
                    output = ""
                }
                
                if (error == nil) {
                    //Call completion handler with string.
                    completionHandler(output)
                } else { // If there is an error...
                    if ( self.errorShouldBeHandled(error!) ) {
                        errorHandler(error!.localizedDescription)
                    }
                }
            }
        )
        //Start POST request.
        postSession.resume()
        
        return postSession
    }
    private class func scheduleWebRequest() -> URLRequest {
        //Create a new NSURLRequest with the correct parameters to download schedule from St. X Website.
        let request = NSMutableURLRequest(url: scheduleURL)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        return request as URLRequest
    }
    private class func scheduleSession() -> URLSession {
        //Create a new NSURLSession with default settings.
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        return session
    }
    private class func requestDataForDate(_ date: Date) -> Data {
        //Create NSData object to send in body of POST request.
        let escapedDate = uploadStringForDate(date)
        let postString: NSString = "export_format=xml&start=\(escapedDate)&end=\(escapedDate)&calendarId=\(scheduleCalenderID)" as NSString
        let postData: Data = postString.data(using: String.Encoding.utf8.rawValue)!
        
        return postData
    }
    private class func uploadStringForDate(_ date: Date) -> String {
        //Returns a correctly formatted string to upload in as a POST parameter.
        let dateFormat: DateFormatter = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy"
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        let formattedDate: String = dateFormat.string(from: date)
        let escapedDate: String = formattedDate.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        return escapedDate
    }
    private class func errorShouldBeHandled(_ error: Error) -> Bool {
        let nsError: NSError = error as NSError
        
        var ignoredError: Bool = false
        ignoredError = ignoredError || (nsError.domain==NSURLErrorDomain && nsError.code==NSURLErrorCancelled)
        
        return !ignoredError
    }
    
}
