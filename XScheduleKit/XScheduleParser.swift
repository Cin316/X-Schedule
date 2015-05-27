//
//  XScheduleParser.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/18/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

public class XScheduleParser: ScheduleParser {
    
    public override func parseForSchedule(string: String, date: NSDate) -> Schedule {
        var schedule = Schedule()
        
        //Parse XML from inputted string.
        var delegate: XScheduleXMLParser = parsedXMLElements(string)

        storeTitleString(delegate.titleString, inSchedule: schedule)
        storeDate(date, inSchedule: schedule)
        println("\(date): {\"\(delegate.descriptionString)\"}")
        storeScheduleBody(delegate.descriptionString, inSchedule: schedule)
        
        //Return finished schedule.
        return schedule
    }
    
    private func parsedXMLElements(string: String) -> XScheduleXMLParser {
        //Returns the parsed XML.
        var stringData = string.dataUsingEncoding(NSUTF8StringEncoding)
        var xmlParser = NSXMLParser(data: stringData!)
        var xmlParserDelegate: NSXMLParserDelegate = XScheduleXMLParser()
        xmlParser.delegate = xmlParserDelegate
        xmlParser.parse()

        return xmlParser.delegate as! XScheduleXMLParser
    }
    
    private func storeDate(date: NSDate, inSchedule schedule: Schedule) {
        schedule.date = date
    }
    private func storeTitleString(string: String, inSchedule schedule: Schedule) {
        var titleString: String = string
        trimWhitespaceFrom(&titleString)
        schedule.title = titleString
    }
    private func storeScheduleBody(scheduleDescription: String, inSchedule schedule: Schedule) {
        
        var scheduleString: String = scheduleDescription
        cleanUpDescriptionString(&scheduleString)
        //Split string up by newlines.
        var lines: [String] = separateLines(scheduleString)
        
        for (num, line) in enumerate(lines) {
            
            //Split each line into tokens.
            var tokens: [String] = separateLineIntoTokens(line)
            //Identify index of time token.
            var timeTokenIndex: Int? = indexOfTimeTokenInArray(tokens)
            
            if (timeTokenIndex == nil) {
                //Only add a timeless ScheduleItem if it has a description.
                if (tokens != []) {
                    //Make schedule item and add to schedule.
                    var item: ScheduleItem = ScheduleItem(blockName: stringFromTokens(tokens))
                    schedule.items.append(item)
                }
            } else {
                //Analyze time token.
                var times: (start: NSDate?, end: NSDate?) = parseArrayForTimes(&tokens, index: timeTokenIndex!, onDate: schedule.date)
                //Make schedule item and add to schedule.
                var item: ScheduleItem = ScheduleItem(blockName: stringFromTokens(tokens), startTime: times.start, endTime: times.end)
                schedule.items.append(item)
            }
        }
    }
    
    private func cleanUpDescriptionString(inout scheduleString: String) {
        trimWhitespaceFrom(&scheduleString)
        removePTags(&scheduleString)
        replaceBRTagsWithNewlines(&scheduleString)
        trimWhitespaceFrom(&scheduleString)
    }
    private func trimWhitespaceFrom(inout string: String) {
        string = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    private func removePTags(inout string: String) {
        //Find p tags.
        var pRangeStart = string.rangeOfString("<p>")
        var pRangeEnd = string.rangeOfString("</p>")
        //Remove p tags.
        if ((pRangeStart) != nil && (pRangeEnd) != nil) {
            var noPRange = (pRangeStart!.endIndex)..<(pRangeEnd!.startIndex)
            string = string.substringWithRange(noPRange)
        }
    }
    private func replaceBRTagsWithNewlines(inout string: String) {
        string = string.stringByReplacingOccurrencesOfString("<br>", withString: "\n")
        string = string.stringByReplacingOccurrencesOfString("<br />", withString: "\n")
    }
    
    private func separateLines(string: String) -> [String] {
        var lines: [String] = string.componentsSeparatedByString("\n")
        
        return lines
    }
    private func separateLineIntoTokens(string: String) -> [String] {
        //If string is empty, return empty output array. Else, separate the string by spaces.
        var tokens: [String]
        if (string == "") {
            tokens = []
        } else {
            tokens = string.componentsSeparatedByString(" ")
        }
        
        return tokens
    }
    
    private func indexOfTimeTokenInArray(tokens: [String]) -> Int? {
        //Search through array for time token and return it's id.
        var timeTokenNum: Int?
        for (i, token) in enumerate(tokens) {
            if (isStringTimeToken(token)) {
                timeTokenNum = i
                break
            }
        }
        
        return timeTokenNum
    }
    private func isStringTimeToken(string: String) -> Bool {
        var hasNums: Bool = string.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet()) != nil
        var hasDash: Bool = string.rangeOfString("-") != nil
        var isTimeToken: Bool = hasNums && hasDash
        
        return isTimeToken
    }
    
    private func analyzeTimeToken(timeToken: String) -> (NSDate?, NSDate?) {
        //Analyze time token.
        var times: (start: String, end: String) = splitTimeToken(timeToken)
        var dateFormatter: NSDateFormatter = setUpParsingDateFormatter()
        
        var startTime: NSDate? = dateFormatter.dateFromString(times.start)
        var endTime: NSDate? = dateFormatter.dateFromString(times.end)
        
        return (startTime, endTime)
    }
    
    private func stringFromTokens(tokensArray: [String]) -> String {
        //Join tokens delimited by spaces and set as desription of ScheduleItem.
        var itemDescription: String = " ".join(tokensArray)
        
        return itemDescription
    }
    
    private func removeArrayItemsAfterIndex<T>(index: Int, inout array: [T]) {
        array.removeRange(index+1..<(array.count))
    }
    
    private func setUpParsingDateFormatter() -> NSDateFormatter {
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        return dateFormatter
    }
    private func splitTimeToken(string: String) -> (String, String) {
        var array: [String] = string.componentsSeparatedByString("-")
        var tuple: (String, String) = (array.first!, array.last!)
        
        return tuple
    }
    private func combineTimeAndDate(#time: NSDate?, date: NSDate) -> NSDate? {
        var combined: NSDate?
        if (time != nil) {
            var dateComponents: NSDateComponents = NSCalendar.currentCalendar().components( .CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitEra, fromDate: date)
            var timeComponents: NSDateComponents = NSCalendar.currentCalendar().components( .CalendarUnitHour | .CalendarUnitMinute, fromDate: time!)
            
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
    private func assignAMPM(inout date: NSDate?) {
        //Hours 12-5 are PM.  Hours 6-11 are AM.
        if (date != nil) {
            var dateComponents: NSDateComponents = NSCalendar.currentCalendar().components( .CalendarUnitHour, fromDate: date!)
            if (dateComponents.hour==12 || dateComponents.hour<5) {
                date = date!.dateByAddingTimeInterval(60*60*12)
            }
        }
    }
    private func addDateInfoToTime(inout time: NSDate?, onDate scheduleDate: NSDate) {
        time = combineTimeAndDate(time: time, date: scheduleDate)
        assignAMPM(&time)
    }
    
    private func parseArrayForTimes(inout tokens: [String], index timeTokenIndex: Int, onDate date: NSDate) -> (NSDate?, NSDate?) {
        //Throw out any tokens after time token.
        removeArrayItemsAfterIndex(timeTokenIndex, array: &tokens)
        
        //Remove time token and transfer to string.
        var timeToken: String = tokens.removeAtIndex(timeTokenIndex)
        
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

    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        currentElement = elementName
    }
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        switch currentElement {
        case "summary":
            titleString += string!
        case "description":
            descriptionString += string!
        default:
            break;
        }
    }

}
