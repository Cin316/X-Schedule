//
//  SubstitutionManager.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 6/11/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

public class SubstitutionManager {
    
    static let substitutionsKey: String = "substitutions"
    static let subSwitchKey: String = "substitutionsEnabled"
    
    static let defaultSubstitutions: [(block: String, className: String)] =
    [("A", "A"),
     ("B", "B")]
    
    public class func substituteItemsInScheduleIfEnabled(schedule: Schedule, substitutions: [(block: String, className: String)]) -> Schedule {
        var output: Schedule
        if (getEnabled()) {
            output = substituteItemsInSchedule(schedule, substitutions: substitutions)
        } else {
            output = schedule
        }
        
        return output
    }
    public class func substituteItemsInSchedule(schedule: Schedule, substitutions: [(block: String, className: String)]) -> Schedule {
        let outputSchedule: Schedule = schedule
        for item in outputSchedule.items {
            for sub in substitutions {
                if item.blockName.uppercaseString == sub.block.uppercaseString {
                    item.blockName = sub.className
                }
            }
        }
        
        return outputSchedule
    }
    
    public class func saveSubstitutions(subs: [(block: String, className: String)]) {
        let arrayVersion: [[String]] = convertTupleToArray(subs)
        
        let defaults = NSUserDefaults.init(suiteName: "group.com.cin316.X-Schedule")!
        defaults.setObject(arrayVersion, forKey: substitutionsKey)
    }
    private class func convertTupleToArray(tuple: [(block: String, className: String)]) -> [[String]] {
        var output: [[String]] = []
        for item in tuple {
            var tmpArray = ["",""]
            tmpArray[0] = item.block.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            tmpArray[1] = item.className.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            output.append(tmpArray)
        }
        
        return output
    }
    
    public class func loadSubstitutions() -> [(block: String, className: String)] {
        let defaults = NSUserDefaults.init(suiteName: "group.com.cin316.X-Schedule")!
        let oldDefaults = NSUserDefaults.standardUserDefaults()
        
        let newObject: AnyObject? = defaults.objectForKey(substitutionsKey)
        let oldObject: AnyObject? = oldDefaults.objectForKey(substitutionsKey)
        
        var tupleVersion: [(block: String, className: String)]
        if let newArray = newObject as? [[String]] {
            tupleVersion = convertArrayToTuple(newArray)
        } else if let oldArray = oldObject as? [[String]] {
            tupleVersion = convertArrayToTuple(oldArray)
        } else {
            tupleVersion = defaultSubstitutions
        }
        
        return tupleVersion
    }
    private class func convertArrayToTuple(array: [[String]]) -> [(block: String, className: String)] {
        var output: [(block: String, className: String)] = []
        for item in array {
            output.append((block: item[0], className: item[1]))
        }
        
        return output
    }
    
    public class func setEnabled(bool: Bool) {
        let defaults = NSUserDefaults.init(suiteName: "group.com.cin316.X-Schedule")!
        defaults.setBool(bool, forKey: subSwitchKey)
    }
    public class func getEnabled() -> Bool {
        let defaults = NSUserDefaults.init(suiteName: "group.com.cin316.X-Schedule")!
        let object: Bool = defaults.boolForKey(subSwitchKey)
        
        return object
    }
    
}
