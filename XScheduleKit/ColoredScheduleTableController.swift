//
//  WhiteScheduleTableController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 4/14/15.
//  Copyright (c) 2015 Nicholas Reichert. All rights reserved.
//

import Foundation

import UIKit

public class WhiteScheduleTableController: ScheduleTableController {
    
    public override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //Fix background color on iPad.
        cell.backgroundColor = UIColor(red: (225.0/255.0), green: (238.0/255.0), blue: (254.0/255.0), alpha: 1.0)
    }
}
