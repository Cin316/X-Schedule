//
//  XScheduleParser.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/18/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

open class XScheduleParser: ScheduleParser {
    
    open override class func storeScheduleInString(_ schedule: Schedule) -> String {
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
    private class func stringForItemsArray(_ items: [ScheduleItem]) -> String {
        var output: String = ""
        for item in items {
            output += "\(item.blockName) \(timeStringForDate(item.startTime as Date?))-\(timeStringForDate(item.endTime as Date?))&lt;br&gt;"
        }
        
        return output
    }
    private class func timeStringForDate(_ date: Date?) -> String {
        var output: String = ""
        let dateFormatter: DateFormatter = setUpParsingDateFormatter()
        
        if (date != nil) {
            output = dateFormatter.string(from: date!)
        } else {
            output = "?:??"
        }
        
        return output
    }
    
    open override class func parseForSchedule(_ string: String, date: Date) -> Schedule {
        let schedule = Schedule()
        
        //Parse XML from inputted string.
        let delegate: XScheduleXMLParser = parsedXMLElements(string)

        storeTitleString(delegate.titleString, inSchedule: schedule)
        storeDate(date, inSchedule: schedule)
        storeScheduleBody(delegate.descriptionString, inSchedule: schedule)
        
        //Return finished schedule.
        return schedule
    }
    
    private class func parsedXMLElements(_ string: String) -> XScheduleXMLParser {
        //Returns the parsed XML.
        let stringData = string.data(using: String.Encoding.utf8)
        let xmlParser = XMLParser(data: stringData!)
        let xmlParserDelegate: XMLParserDelegate = XScheduleXMLParser()
        xmlParser.delegate = xmlParserDelegate
        xmlParser.parse()

        return xmlParser.delegate as! XScheduleXMLParser
    }
    
    private class func storeDate(_ date: Date, inSchedule schedule: Schedule) {
        schedule.date = date
    }
    private class func storeTitleString(_ string: String, inSchedule schedule: Schedule) {
        var titleString: String = string
        trimWhitespaceFrom(&titleString)
        schedule.title = titleString
    }
    private class func storeScheduleBody(_ scheduleDescription: String, inSchedule schedule: Schedule) {
        
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
                let times: (start: Date?, end: Date?) = parseArrayForTimes(&tokens, index: timeTokenIndex!, onDate: schedule.date as Date)
                //Make schedule item and add to schedule.
                let item: ScheduleItem = ScheduleItem(blockName: stringFromTokens(tokens), startTime: times.start, endTime: times.end)
                schedule.items.append(item)
            }
        }
    }
    
    private class func cleanUpDescriptionString(_ scheduleString: inout String) {
        trimWhitespaceFrom(&scheduleString)
        removePTags(&scheduleString)
        replaceBRTagsWithNewlines(&scheduleString)
        trimWhitespaceFrom(&scheduleString)
    }
    private class func trimWhitespaceFrom(_ string: inout String) {
        string = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    private class func removePTags(_ string: inout String) {
        //Find p tags.
        let pRangeStart = string.range(of: "<p>")
        let pRangeEnd = string.range(of: "</p>")
        //Remove p tags.
        if ((pRangeStart) != nil && (pRangeEnd) != nil) {
            let noPRange = (pRangeStart!.upperBound)..<(pRangeEnd!.lowerBound)
            string = string.substring(with: noPRange)
        }
    }
    private class func replaceBRTagsWithNewlines(_ string: inout String) {
        string = string.replacingOccurrences(of: "<br>", with: "\n")
        string = string.replacingOccurrences(of: "<br />", with: "\n")
    }
    
    private class func separateLines(_ string: String) -> [String] {
        let lines: [String] = string.components(separatedBy: "\n")
        
        return lines
    }
    private class func separateLineIntoTokens(_ string: String) -> [String] {
        //If string is empty, return empty output array. Else, separate the string by spaces.
        var tokens: [String]
        if (string == "") {
            tokens = []
        } else {
            tokens = string.components(separatedBy: " ")
        }
        
        return tokens
    }
    
    private class func indexOfTimeTokenInArray(_ tokens: [String]) -> Int? {
        //Search through array for time token and return it's id.
        var timeTokenNum: Int?
        for (i, token) in tokens.enumerated() {
            if (isStringTimeToken(token)) {
                timeTokenNum = i
                break
            }
        }
        
        return timeTokenNum
    }
    private class func isStringTimeToken(_ string: String) -> Bool {
        let hasNums: Bool = string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
        let hasQuestionMark: Bool = string.range(of: "?") != nil
        let hasDash: Bool = string.range(of: "-") != nil
        let isTimeToken: Bool = (hasQuestionMark || hasNums) && hasDash
        
        return isTimeToken
    }
    
    private class func analyzeTimeToken(_ timeToken: String) -> (Date?, Date?) {
        //Analyze time token.
        let times: (start: String, end: String) = splitTimeToken(timeToken)
        let dateFormatter: DateFormatter = setUpParsingDateFormatter()
        
        let startTime: Date? = dateFormatter.date(from: times.start)
        let endTime: Date? = dateFormatter.date(from: times.end)
        
        return (startTime, endTime)
    }
    
    private class func stringFromTokens(_ tokensArray: [String]) -> String {
        //Join tokens delimited by spaces and set as desription of ScheduleItem.
        let itemDescription: String = tokensArray.joined(separator: " ")
        let trimmedDescription: String = itemDescription.trimmingCharacters(in: .whitespaces)
        
        return trimmedDescription
    }
    
    private class func removeArrayItemsAfterIndex<T>(_ index: Int, array: inout [T]) {
        array.removeSubrange(index+1..<(array.count))
    }
    
    private class func setUpParsingDateFormatter() -> DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return dateFormatter
    }
    private class func splitTimeToken(_ string: String) -> (String, String) {
        let array: [String] = string.components(separatedBy: "-")
        let tuple: (String, String) = (array.first!, array.last!)
        
        return tuple
    }
    private class func combineTimeAndDate(time: Date?, date: Date) -> Date? {
        var combined: Date?
        if (time != nil) {
            let dateComponents: DateComponents = (Calendar.current as NSCalendar).components( [.day, .month, .year, .era], from: date)
            var timeComponents: DateComponents = (Calendar.current as NSCalendar).components( [.hour, .minute], from: time!)
            
            timeComponents.day = dateComponents.day
            timeComponents.month = dateComponents.month
            timeComponents.year = dateComponents.year
            timeComponents.era = dateComponents.era
            
            combined = Calendar.current.date(from: timeComponents)
        } else {
            combined = nil
        }
        
        return combined
    }
    private class func assignAMPM(_ date: inout Date?) {
        //Hours 12-5 are PM.  Hours 6-11 are AM.
        if (date != nil) {
            let dateComponents: DateComponents = (Calendar.current as NSCalendar).components( .hour, from: date!)
            if (dateComponents.hour!==12 || dateComponents.hour!<5) {
                date = date!.addingTimeInterval(60*60*12)
            }
        }
    }
    private class func addDateInfoToTime(_ time: inout Date?, onDate scheduleDate: Date) {
        time = combineTimeAndDate(time: time, date: scheduleDate)
        assignAMPM(&time)
    }
    
    private class func parseArrayForTimes(_ tokens: inout [String], index timeTokenIndex: Int, onDate date: Date) -> (Date?, Date?) {
        //Throw out any tokens after time token.
        removeArrayItemsAfterIndex(timeTokenIndex, array: &tokens)
        
        //Remove time token and transfer to string.
        let timeToken: String = tokens.remove(at: timeTokenIndex)
        
        //Analyze time token.
        var times: (start: Date?, end: Date?) = analyzeTimeToken(timeToken)
        
        //Put time tokens on the schedule date.
        addDateInfoToTime(&times.start, onDate: date)
        addDateInfoToTime(&times.end, onDate: date)
        
        return times
    }
}

class XScheduleXMLParser: NSObject, XMLParserDelegate {

    var descriptionString = ""
    var titleString = ""
    private var currentElement = ""

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
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
