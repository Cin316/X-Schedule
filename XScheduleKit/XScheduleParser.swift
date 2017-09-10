//
//  XScheduleParser.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/18/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

open class XScheduleParser: ScheduleParser {
    
    static let manualNotificationTriggerKeyword = "<!--send_notification-->"
    
    open override class func storeScheduleInString(_ schedule: Schedule) -> String {
        var output: String = ""
        output += "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        output += "<schedule>\n"
        output += "<summary>\(schedule.title)</summary>\n"
        output += "<description>&lt;p&gt;"
        output += "\(stringForItemsArray(schedule.items))"
        output += "&lt;/p&gt;</description>\n"
        output += "\(manualNotificationTrigger(schedule))\n"
        output += "</schedule>"
        
        return output
    }
    private class func stringForItemsArray(_ items: [ScheduleItem]) -> String {
        var output: String = ""
        for item in items {
            if let spanItem = item as? TimeSpanScheduleItem {
                output += "\(spanItem.blockName) \(timeStringForDate(spanItem.startTime as Date?))-\(timeStringForDate(spanItem.endTime as Date?))"
            } else if let spanItem = item as? TimePointScheduleItem {
                output += "\(spanItem.blockName) \(timeStringForDate(spanItem.time as Date?))"
            } else if let spanItem = item as? DescriptionScheduleItem {
                output += "\(spanItem.blockName)"
            }
            // Always finish each item with a line break tag <br>.
            output += "&lt;br&gt;"
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
    private class func manualNotificationTrigger(_ schedule: Schedule) -> String {
        if (schedule.manuallyMarkedUnusual) {
            return manualNotificationTriggerKeyword
        } else {
            return ""
        }
    }
    
    open override class func parseForSchedule(_ string: String, date: Date) -> Schedule {
        let schedule = Schedule()
        
        //Parse XML from inputted string.
        let delegate: XScheduleXMLParser = parsedXMLElements(string)
        
        storeManualNotificationTrigger(string, inSchedule: schedule)
        storeTitleString(delegate.titleString, inSchedule: schedule)
        storeDate(date, inSchedule: schedule)
        storeScheduleBody(delegate.descriptionString, inSchedule: schedule)
        removeCodeScheduleItems(inSchedule: schedule)
        
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
    
    private class func removeCodeScheduleItems(inSchedule schedule: Schedule) {
        // Removes all elements that contain the manualNotificationTriggerKeyword.
        schedule.items = schedule.items.filter( { !$0.primaryText().contains(manualNotificationTriggerKeyword) } )
    }
    
    private class func storeManualNotificationTrigger(_ string: String, inSchedule schedule: Schedule) {
        if (string.contains(manualNotificationTriggerKeyword)) {
            schedule.manuallyMarkedUnusual = true
        }
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
            let singleTimeTokenIndex: Int? = indexOfSingleTimeTokenInArray(tokens)
            let doubleTimeTokenIndex: Int? = indexOfDoubleTimeTokenInArray(tokens)
            
            if (singleTimeTokenIndex == nil && doubleTimeTokenIndex == nil) {
                //Only add a timeless ScheduleItem if it has a description.
                if (tokens != []) {
                    //Make schedule item and add to schedule.
                    let item: DescriptionScheduleItem = DescriptionScheduleItem(blockName: stringFromTokens(tokens))
                    schedule.items.append(item)
                }
            } else if ( doubleTimeTokenIndex != nil) {
                //Analyze time token.
                let times: (start: Date?, end: Date?) = parseTokensForDoubleTimes(&tokens, index: doubleTimeTokenIndex!, onDate: schedule.date as Date)
                
                //Make schedule item and add to schedule.
                let item: TimeSpanScheduleItem = TimeSpanScheduleItem(blockName: stringFromTokens(tokens), startTime: times.start, endTime: times.end)
                schedule.items.append(item)
            } else { // singleTimeTokenIndex != nil
                //Analyze time token.
                let time: Date? = parseTokensForSingleTime(&tokens, index: singleTimeTokenIndex!, onDate: schedule.date as Date)
                
                //Make schedule item and add to schedule.
                let item: TimePointScheduleItem = TimePointScheduleItem(blockName: stringFromTokens(tokens), time: time)
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
    
    private class func indexOfDoubleTimeTokenInArray(_ tokens: [String]) -> Int? {
        //Search through array for time token and return it's id.
        
        return tokens.index(where: { isStringDoubleTimeToken($0) } )
    }
    private class func isStringDoubleTimeToken(_ string: String) -> Bool {
        let hasNums: Bool = string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
        let hasQuestionMark: Bool = string.range(of: "?") != nil
        let hasDash: Bool = string.range(of: "-") != nil
        let hasColon: Bool = string.range(of: ":") != nil
        let isTimeToken: Bool = (hasQuestionMark || hasNums) && hasDash && hasColon
        
        return isTimeToken
    }
    private class func indexOfSingleTimeTokenInArray(_ tokens: [String]) -> Int? {
        //Search through array for time token and return it's id.
        
        return tokens.index(where: { isStringSingleTimeToken($0) } )
    }
    private class func isStringSingleTimeToken(_ string: String) -> Bool {
        let hasNums: Bool = string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
        let hasQuestionMark: Bool = string.range(of: "?") != nil
        let hasDash: Bool = string.range(of: "-") != nil
        let hasColon: Bool = string.range(of: ":") != nil
        let isTimeToken: Bool = (hasQuestionMark || hasNums) && !hasDash && hasColon
        
        return isTimeToken
    }
    
    private class func analyzeDoubleTimeToken(_ timeToken: String) -> (Date?, Date?) {
        //Analyze time token.
        let times: (start: String, end: String) = splitDoubleTimeToken(timeToken)
        let dateFormatter: DateFormatter = setUpParsingDateFormatter()
        
        let startTime: Date? = dateFormatter.date(from: times.start)
        let endTime: Date? = dateFormatter.date(from: times.end)
        
        return (startTime, endTime)
    }
    private class func analyzeSingleTimeToken(_ timeToken: String) -> Date? {
        //Analyze time token.
        let dateFormatter: DateFormatter = setUpParsingDateFormatter()
        
        let time: Date? = dateFormatter.date(from: timeToken)
        
        return time
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
    private class func splitDoubleTimeToken(_ string: String) -> (String, String) {
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
    
    // Search through a tokens array with a double time token and extract the start and end times from it.
    private class func parseTokensForDoubleTimes(_ tokens: inout [String], index timeTokenIndex: Int, onDate date: Date) -> (Date?, Date?) {
        //Throw out any tokens after time token.
        removeArrayItemsAfterIndex(timeTokenIndex, array: &tokens)
        
        //Remove time token and transfer to string.
        let timeToken: String = tokens.remove(at: timeTokenIndex)
        
        //Analyze time token.
        var times: (start: Date?, end: Date?) = analyzeDoubleTimeToken(timeToken)
        
        //Put time tokens on the schedule date.
        addDateInfoToTime(&times.start, onDate: date)
        addDateInfoToTime(&times.end, onDate: date)
        
        return times
    }
    
    // Search through a tokens array with a single time token and extract the time from it.
    private class func parseTokensForSingleTime(_ tokens: inout [String], index timeTokenIndex: Int, onDate date: Date) -> Date? {
        //Throw out any tokens after time token.
        removeArrayItemsAfterIndex(timeTokenIndex, array: &tokens)
        
        //Remove time token and transfer to string.
        let timeToken: String = tokens.remove(at: timeTokenIndex)
        
        //Analyze time token.
        var time: Date? = analyzeSingleTimeToken(timeToken)
        
        //Put time tokens on the schedule date.
        addDateInfoToTime(&time, onDate: date)
        
        return time
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
