//
//  SubstitutionManager.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 6/11/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

open class SubstitutionManager {
    
    static let substitutionsKey: String = "substitutions"
    static let subSwitchKey: String = "substitutionsEnabled"
    
    static let defaultSubstitutions: [(block: String, className: String)] =
    [("A", "A"),
     ("B", "B")]
    
    open class func substituteItemsInScheduleIfEnabled(_ schedule: Schedule, substitutions: [(block: String, className: String)]) -> Schedule {
        var output: Schedule
        if (getEnabled()) {
            output = substituteItemsInSchedule(schedule, substitutions: substitutions)
        } else {
            output = schedule
        }
        
        return output
    }
    open class func substituteItemsInSchedule(_ schedule: Schedule, substitutions: [(block: String, className: String)]) -> Schedule {
        let outputSchedule: Schedule = schedule
        for item in outputSchedule.items {
            for sub in substitutions {
                if trimWhitespaceFrom(item.blockName.uppercased()) == trimWhitespaceFrom(sub.block.uppercased()) {
                    item.blockName = sub.className
                }
            }
        }
        
        return outputSchedule
    }
    private class func trimWhitespaceFrom(_ string: String) -> String {
        return string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    open class func saveSubstitutions(_ subs: [(block: String, className: String)]) {
        let arrayVersion: [[String]] = convertTupleToArray(subs)
        
        let defaults = UserDefaults.init(suiteName: "group.com.cin316.X-Schedule")!
        defaults.set(arrayVersion, forKey: substitutionsKey)
    }
    private class func convertTupleToArray(_ tuple: [(block: String, className: String)]) -> [[String]] {
        var output: [[String]] = []
        for item in tuple {
            var tmpArray = ["",""]
            tmpArray[0] = item.block.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            tmpArray[1] = item.className.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            output.append(tmpArray)
        }
        
        return output
    }
    
    open class func loadSubstitutions() -> [(block: String, className: String)] {
        let defaults = UserDefaults.init(suiteName: "group.com.cin316.X-Schedule")!
        let oldDefaults = UserDefaults.standard
        
        let newObject: AnyObject? = defaults.object(forKey: substitutionsKey) as AnyObject?
        let oldObject: AnyObject? = oldDefaults.object(forKey: substitutionsKey) as AnyObject?
        
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
    private class func convertArrayToTuple(_ array: [[String]]) -> [(block: String, className: String)] {
        var output: [(block: String, className: String)] = []
        for item in array {
            output.append((block: item[0], className: item[1]))
        }
        
        return output
    }
    
    open class func setEnabled(_ bool: Bool) {
        let defaults = UserDefaults.init(suiteName: "group.com.cin316.X-Schedule")!
        defaults.set(bool, forKey: subSwitchKey)
    }
    open class func getEnabled() -> Bool {
        let defaults = UserDefaults.init(suiteName: "group.com.cin316.X-Schedule")!
        let object: Bool = defaults.bool(forKey: subSwitchKey)
        
        return object
    }
    
}
