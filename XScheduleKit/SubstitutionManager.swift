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
        for (var i=0; i<schedule.items.count; i++) {
            for sub in substitutions {
                if outputSchedule.items[i].blockName == sub.block {
                    outputSchedule.items[i].blockName = sub.className
                }
            }
        }
        
        return outputSchedule
    }
    
    public class func saveSubstitutions(subs: [(block: String, className: String)]) {
        let arrayVersion: [[String]] = convertTupleToArray(subs)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(arrayVersion, forKey: substitutionsKey)
    }
    private class func convertTupleToArray(tuple: [(block: String, className: String)]) -> [[String]] {
        var output: [[String]] = []
        for item in tuple {
            var tmpArray = ["",""]
            tmpArray[0] = item.block
            tmpArray[1] = item.className
            output.append(tmpArray)
        }
        
        return output
    }
    
    public class func loadSubstitutions() -> [(block: String, className: String)] {
        let defaults = NSUserDefaults.standardUserDefaults()
        let object: AnyObject? = defaults.objectForKey(substitutionsKey)
        
        var tupleVersion: [(block: String, className: String)]
        if let array = object as? [[String]] {
            tupleVersion = convertArrayToTuple(array)
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
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(bool, forKey: subSwitchKey)
    }
    public class func getEnabled() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        let object: Bool = defaults.boolForKey(subSwitchKey)
        
        return object
    }
    
}
