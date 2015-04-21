//
//  ScheduleParser.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/18/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

public class ScheduleParser: NSObject, NSXMLParserDelegate {
    
    var descriptionString = ""
    var titleString = ""
    var dateString = ""
    var currentElement = ""
    
    public func parseForSchedule(string: String, date: NSDate) -> Schedule {
        //Setup variables
        var items = [ScheduleItem]()
        var schedule = Schedule(items: items)
        var stringData = string.dataUsingEncoding(NSUTF8StringEncoding)
        var xmlParser = NSXMLParser(data: stringData!)
        xmlParser.delegate = self
        
        //Parsing code.
        
        //Parse XML.
        xmlParser.parse()
        
        //Put title into Schedule.
        titleString = titleString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        schedule.title = titleString
        
        
        //Trim whitespace.
        dateString = dateString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        //Store date.
        schedule.date = date
        
        //Parse description.
        //Trim whitespace.
        descriptionString = descriptionString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        //Only use text between the <p> tags.  Delete <p> tags.
        var pRangeStart = descriptionString.rangeOfString("<p>")
        var pRangeEnd = descriptionString.rangeOfString("</p>")
        
        //If <p> tags aren't present, skip string parsing.
        if ((pRangeStart) != nil && (pRangeEnd) != nil){
            
            //Remove <p> tags
            var noPRange = (pRangeStart!.endIndex)..<(pRangeEnd!.startIndex)
            descriptionString = descriptionString.substringWithRange(noPRange)
            
            //Replace all <br> with \n
            descriptionString = descriptionString.stringByReplacingOccurrencesOfString("<br>", withString: "\n")
            
            //Remove whitespace.
            descriptionString = descriptionString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            //Split string up by newlines.
            var lines = descriptionString.componentsSeparatedByString("\n")
            
            //Make array for w
            var missingTime: [Bool] = [Bool](count: lines.count, repeatedValue: false)
            
            for (num, line) in enumerate(lines) {
                //Split each line into tokens.
                var tokens = line.componentsSeparatedByString(" ")
                
                //Identify time token. It contains numbers and "-".
                var timeTokenNum: Int = Int.max
                var i = 0
                for token in tokens {
                    var hasNums = token.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet()) != nil
                    var hasDash = token.rangeOfString("-") != nil
                    if (hasNums && hasDash) {
                        timeTokenNum = i
                        break
                    }
                    i++
                }
                
                //If a time token isn't found, mark in missingTime array.
                if (timeTokenNum == Int.max) {
                    missingTime[num] = true
                    
                    //Combine tokens into item description & add to ScheduleItem.
                    var item: ScheduleItem = ScheduleItem(blockName: " ".join(tokens))
                    
                    //Add item to schedule.
                    schedule.items.append(item)

                } else {
                
                    //Throw out any tokens after time token.
                    tokens.removeRange(timeTokenNum+1..<(tokens.count))
                
                    //Remove time token and transfer to string.
                    var timeToken: String = tokens[timeTokenNum]
                    tokens.removeAtIndex(timeTokenNum)
                
                    //Combine remaining tokens into item description & add to ScheduleItem.
                    var item: ScheduleItem = ScheduleItem(blockName: " ".join(tokens))
                
                    //Analyze time token.
                    var times = timeToken.componentsSeparatedByString("-")
                    var startTime: NSDate = NSDate()
                    var endTime: NSDate = NSDate()
                    var foundTime: Bool = false
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "h:mm"
                    for time in times {
                        if (time != "") {
                            //Convert strings into dates.
                            if (foundTime == false) {
                                startTime = dateFormatter.dateFromString(time)!
                                foundTime = true
                            } else {
                                endTime = dateFormatter.dateFromString(time)!
                            }
                        }
                    }
                    
                    //Put time tokens on the schedule date.
                    var dateComponents: NSDateComponents = NSCalendar.currentCalendar().components( .CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitEra, fromDate: schedule.date)
                    var startTimeComponents: NSDateComponents = NSCalendar.currentCalendar().components( .CalendarUnitHour | .CalendarUnitMinute, fromDate: startTime)
                    var endTimeComponents: NSDateComponents = NSCalendar.currentCalendar().components( .CalendarUnitHour | .CalendarUnitMinute, fromDate: endTime)
                    
                    startTimeComponents.day = dateComponents.day
                    startTimeComponents.month = dateComponents.month
                    startTimeComponents.year = dateComponents.year
                    startTimeComponents.era = dateComponents.era
                    
                    endTimeComponents.day = dateComponents.day
                    endTimeComponents.month = dateComponents.month
                    endTimeComponents.year = dateComponents.year
                    endTimeComponents.era = dateComponents.era
                    
                    startTime = NSCalendar.currentCalendar().dateFromComponents(startTimeComponents)!
                    endTime = NSCalendar.currentCalendar().dateFromComponents(endTimeComponents)!
                    
                    //Hours 12-5 are PM.  Hours 6-11 are AM.
                    if (startTimeComponents.hour==12 || startTimeComponents.hour<5) {
                        startTime = startTime.dateByAddingTimeInterval(60*60*12)
                    }
                    if (endTimeComponents.hour==12 || endTimeComponents.hour<5) {
                        endTime = endTime.dateByAddingTimeInterval(60*60*12)
                    }
                    
                    //Store start and end times in schedule.
                    item.startTime = startTime
                    item.endTime = endTime

                    //Add item to schedule.
                    schedule.items.append(item)
                
                }
            }
            
            //Loop through a fill in times where they are missing.
            for (i, item) in enumerate(schedule.items) {
                //Check if time is missing.
                if (missingTime[i]) {
                    
                    //Find start time.
                    if (i == 0) { //First item.
                        //Set start time to 8:00.
                        var dateComps = NSDateComponents()
                        dateComps.hour = 8
                        dateComps.minute = 00
                        var calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                        schedule.items[i].startTime = calendar.dateFromComponents(dateComps)!
                    } else {
                        schedule.items[i].startTime = schedule.items[i-1].endTime
                    }
                    
                    //Find end time.
                    if (i == schedule.items.count-1) { //Last item.
                        //Set end time to 3:04.
                        var dateComps = NSDateComponents()
                        dateComps.hour = 3+12
                        dateComps.minute = 04
                        var calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                        schedule.items[i].endTime = calendar.dateFromComponents(dateComps)!
                    } else {
                        schedule.items[i].endTime = schedule.items[i+1].startTime
                    }
                }
            }
        }
        
        //Return finished schedule.
        return schedule
    }
    
    public func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        currentElement = elementName
    }
    public func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
    }
    
    public func parser(parser: NSXMLParser, foundCharacters string: String?) {
        switch currentElement {
        case "summary":
            titleString += string!
        case "description":
            descriptionString += string!
        case "dtstart":
            dateString += string!
        default:
            break;
        }
    }
    
}