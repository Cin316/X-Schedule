//
//  ColoredScheduleTableController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 4/14/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import Foundation

import UIKit

public class ColoredScheduleTableController: ScheduleTableController {
    
    private var internalCellColor: UIColor = UIColor(red: (225.0/255.0), green: (238.0/255.0), blue: (254.0/255.0), alpha: 1.0)
    private var internalHighlightedColor: UIColor = UIColor(red: (251.0/255.0), green: (250.0/255.0), blue: (146.0/255.0), alpha: 1.0)
    
    public override func cellColor() -> UIColor {
        return internalCellColor
    }
    public override func highlightedColor() -> UIColor {
        return  internalHighlightedColor
    }
    
}
