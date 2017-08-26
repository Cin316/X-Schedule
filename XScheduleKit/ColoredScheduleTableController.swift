//
//  ColoredScheduleTableController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 4/14/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

import UIKit

open class ColoredScheduleTableController: ScheduleTableController {
    
    private var internalCellColor: UIColor = UIColor(red: (225.0/255.0), green: (238.0/255.0), blue: (254.0/255.0), alpha: 1.0)
    private var internalHighlightedColor: UIColor = UIColor(red: (251.0/255.0), green: (250.0/255.0), blue: (146.0/255.0), alpha: 1.0)
    
    open override func cellColor() -> UIColor {
        return internalCellColor
    }
    open override func highlightedColor() -> UIColor {
        return  internalHighlightedColor
    }
    
}
