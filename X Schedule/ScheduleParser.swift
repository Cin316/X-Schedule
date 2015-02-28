//
//  ScheduleParser.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 2/18/15.
//  Copyright (c) 2015 Nicholas Reichert. All rights reserved.
//

import Foundation

class ScheduleParser: NSObject, NSXMLParserDelegate {
    
    var descriptionString = ""
    var titleString = ""
    var dateString = ""
    var currentElement = ""
    
    func parseForSchedule(string: String) -> Schedule {
        //Setup variables
        var items = [ScheduleItem]()
        var schedule = Schedule(items: items)
        var stringData = string.dataUsingEncoding(NSUTF8StringEncoding)
        var xmlParser = NSXMLParser(data: stringData)
        xmlParser.delegate = self
        
        //Parsing code.
        
        //Parse XML.
        xmlParser.parse()
        
        //Put title into Schedule.
        titleString = titleString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        schedule.title = titleString
        
        
        //Trim whitespace.
        dateString = dateString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        //Get and parse date.
        var dayFormatter = NSDateFormatter()
        dayFormatter.dateFormat = "yyyyMMdd"
        var dayDate: NSDate? = dayFormatter.dateFromString(dateString)
        
        if let realDayDate = dayDate {
            schedule.date = realDayDate
        }
        
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
            for line in lines {
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
                item.startTime = startTime
                item.endTime = endTime

                //Add item to schedule.
                schedule.items.append(item)
            }
        }
        
        //Return finished schedule.
        return schedule
    }
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        currentElement = elementName
    }
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        switch currentElement {
        case "summary":
            titleString += string
        case "description":
            descriptionString += string
        case "dtstart":
            dateString += string
        default:
            break;
        }
    }
    
}