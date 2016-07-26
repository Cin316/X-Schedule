//
//  XScheduleParser.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/18/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

public class XScheduleParser: ScheduleParser {
    
    public override class func storeScheduleInString(schedule: Schedule) -> String {
        var output: String = ""
        output += "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        output += "<schedule>\n"
        output += "<summary>\(schedule.title)</summary>\n"
        output += "<description>&lt;p&gt;"
        output += "\(stringForItemsArray(schedule.items))"
        output += "&lt;/p&gt;</description>\n"
        output += "</schedule>"
        
        return output
    }
    private class func stringForItemsArray(items: [ScheduleItem]) -> String {
        var output: String = ""
        for item in items {
            output += "\(item.blockName) \(timeStringForDate(item.startTime))-\(timeStringForDate(item.endTime))&lt;br&gt;"
        }
        
        return output
    }
    private class func timeStringForDate(date: NSDate?) -> String {
        var output: String = ""
        let dateFormatter: NSDateFormatter = setUpParsingDateFormatter()
        
        if (date != nil) {
            output = dateFormatter.stringFromDate(date!)
        } else {
            output = "?:??"
        }
        
        return output
    }
    
    public override class func parseForSchedule(string: String, date: NSDate) -> Schedule {
        let schedule = Schedule()
        
        //Parse XML from inputted string.
        let delegate: XScheduleXMLParser = parsedXMLElements(string)

        storeTitleString(delegate.titleString, inSchedule: schedule)
        storeDate(date, inSchedule: schedule)
        storeScheduleBody(delegate.descriptionString, inSchedule: schedule)
        
        //Return finished schedule.
        return schedule
    }
    
    private class func parsedXMLElements(string: String) -> XScheduleXMLParser {
        //Returns the parsed XML.
        let stringData = string.dataUsingEncoding(NSUTF8StringEncoding)
        let xmlParser = NSXMLParser(data: stringData!)
        let xmlParserDelegate: NSXMLParserDelegate = XScheduleXMLParser()
        xmlParser.delegate = xmlParserDelegate
        xmlParser.parse()

        return xmlParser.delegate as! XScheduleXMLParser
    }
    
    private class func storeDate(date: NSDate, inSchedule schedule: Schedule) {
        schedule.date = date
    }
    private class func storeTitleString(string: String, inSchedule schedule: Schedule) {
        var titleString: String = string
        trimWhitespaceFrom(&titleString)
        schedule.title = titleString
    }
    private class func storeScheduleBody(scheduleDescription: String, inSchedule schedule: Schedule) {
        
        var scheduleString: String = scheduleDescription
        cleanUpDescriptionString(&scheduleString)
        //Split string up by newlines.
        let lines: [String] = separateLines(scheduleString)
        
        for line in lines {
            
            //Split each line into tokens.
            var tokens: [String] = separateLineIntoTokens(line)
            //Identify index of time token.
            let timeTokenIndex: Int? = indexOfTimeTokenInArray(tokens)
            
            if (timeTokenIndex == nil) {
                //Only add a timeless ScheduleItem if it has a description.
                if (tokens != []) {
                    //Make schedule item and add to schedule.
                    let item: ScheduleItem = ScheduleItem(blockName: stringFromTokens(tokens))
                    schedule.items.append(item)
                }
            } else {
                //Analyze time token.
                let times: (start: NSDate?, end: NSDate?) = parseArrayForTimes(&tokens, index: timeTokenIndex!, onDate: schedule.date)
                //Make schedule item and add to schedule.
                let item: ScheduleItem = ScheduleItem(blockName: stringFromTokens(tokens), startTime: times.start, endTime: times.end)
                schedule.items.append(item)
            }
        }
    }
    
    private class func cleanUpDescriptionString(inout scheduleString: String) {
        trimWhitespaceFrom(&scheduleString)
        removePTags(&scheduleString)
        replaceBRTagsWithNewlines(&scheduleString)
        trimWhitespaceFrom(&scheduleString)
    }
    private class func trimWhitespaceFrom(inout string: String) {
        string = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    private class func removePTags(inout string: String) {
        //Find p tags.
        let pRangeStart = string.rangeOfString("<p>")
        let pRangeEnd = string.rangeOfString("</p>")
        //Remove p tags.
        if ((pRangeStart) != nil && (pRangeEnd) != nil) {
            let noPRange = (pRangeStart!.endIndex)..<(pRangeEnd!.startIndex)
            string = string.substringWithRange(noPRange)
        }
    }
    private class func replaceBRTagsWithNewlines(inout string: String) {
        string = string.stringByReplacingOccurrencesOfString("<br>", withString: "\n")
        string = string.stringByReplacingOccurrencesOfString("<br />", withString: "\n")
    }
    
    private class func separateLines(string: String) -> [String] {
        let lines: [String] = string.componentsSeparatedByString("\n")
        
        return lines
    }
    private class func separateLineIntoTokens(string: String) -> [String] {
        //If string is empty, return empty output array. Else, separate the string by spaces.
        var tokens: [String]
        if (string == "") {
            tokens = []
        } else {
            tokens = string.componentsSeparatedByString(" ")
        }
        
        return tokens
    }
    
    private class func indexOfTimeTokenInArray(tokens: [String]) -> Int? {
        //Search through array for time token and return it's id.
        var timeTokenNum: Int?
        for (i, token) in tokens.enumerate() {
            if (isStringTimeToken(token)) {
                timeTokenNum = i
                break
            }
        }
        
        return timeTokenNum
    }
    private class func isStringTimeToken(string: String) -> Bool {
        let hasNums: Bool = string.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet()) != nil
        let hasQuestionMark: Bool = string.rangeOfString("?") != nil
        let hasDash: Bool = string.rangeOfString("-") != nil
        let isTimeToken: Bool = (hasQuestionMark || hasNums) && hasDash
        
        return isTimeToken
    }
    
    private class func analyzeTimeToken(timeToken: String) -> (NSDate?, NSDate?) {
        //Analyze time token.
        let times: (start: String, end: String) = splitTimeToken(timeToken)
        let dateFormatter: NSDateFormatter = setUpParsingDateFormatter()
        
        let startTime: NSDate? = dateFormatter.dateFromString(times.start)
        let endTime: NSDate? = dateFormatter.dateFromString(times.end)
        
        return (startTime, endTime)
    }
    
    private class func stringFromTokens(tokensArray: [String]) -> String {
        //Join tokens delimited by spaces and set as desription of ScheduleItem.
        let itemDescription: String = tokensArray.joinWithSeparator(" ")
        let trimmedDescription: String = itemDescription.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
        
        return trimmedDescription
    }
    
    private class func removeArrayItemsAfterIndex<T>(index: Int, inout array: [T]) {
        array.removeRange(index+1..<(array.count))
    }
    
    private class func setUpParsingDateFormatter() -> NSDateFormatter {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        return dateFormatter
    }
    private class func splitTimeToken(string: String) -> (String, String) {
        let array: [String] = string.componentsSeparatedByString("-")
        let tuple: (String, String) = (array.first!, array.last!)
        
        return tuple
    }
    private class func combineTimeAndDate(time time: NSDate?, date: NSDate) -> NSDate? {
        var combined: NSDate?
        if (time != nil) {
            let dateComponents: NSDateComponents = NSCalendar.currentCalendar().components( [.Day, .Month, .Year, .Era], fromDate: date)
            let timeComponents: NSDateComponents = NSCalendar.currentCalendar().components( [.Hour, .Minute], fromDate: time!)
            
            timeComponents.day = dateComponents.day
            timeComponents.month = dateComponents.month
            timeComponents.year = dateComponents.year
            timeComponents.era = dateComponents.era
            
            combined = NSCalendar.currentCalendar().dateFromComponents(timeComponents)
        } else {
            combined = nil
        }
        
        return combined
    }
    private class func assignAMPM(inout date: NSDate?) {
        //Hours 12-5 are PM.  Hours 6-11 are AM.
        if (date != nil) {
            let dateComponents: NSDateComponents = NSCalendar.currentCalendar().components( .Hour, fromDate: date!)
            if (dateComponents.hour==12 || dateComponents.hour<5) {
                date = date!.dateByAddingTimeInterval(60*60*12)
            }
        }
    }
    private class func addDateInfoToTime(inout time: NSDate?, onDate scheduleDate: NSDate) {
        time = combineTimeAndDate(time: time, date: scheduleDate)
        assignAMPM(&time)
    }
    
    private class func parseArrayForTimes(inout tokens: [String], index timeTokenIndex: Int, onDate date: NSDate) -> (NSDate?, NSDate?) {
        //Throw out any tokens after time token.
        removeArrayItemsAfterIndex(timeTokenIndex, array: &tokens)
        
        //Remove time token and transfer to string.
        let timeToken: String = tokens.removeAtIndex(timeTokenIndex)
        
        //Analyze time token.
        var times: (start: NSDate?, end: NSDate?) = analyzeTimeToken(timeToken)
        
        //Put time tokens on the schedule date.
        addDateInfoToTime(&times.start, onDate: date)
        addDateInfoToTime(&times.end, onDate: date)
        
        return times
    }
}

class XScheduleXMLParser: NSObject, NSXMLParserDelegate {

    var descriptionString = ""
    var titleString = ""
    private var currentElement = ""

    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
    }
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        switch currentElement {
        case "summary":
            titleString += string
        case "description":
            descriptionString += string
        default:
            break;
        }
    }

}
