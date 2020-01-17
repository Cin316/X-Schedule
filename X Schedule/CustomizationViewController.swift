//
//  CustomizationViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 6/9/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit
import XScheduleKit

class CustomizationViewController: UITableViewController {
    
    var substitutions: [(block: String, className: String)] = SubstitutionManager.loadSubstitutions()
    
    var selectedNum: Int = 0
    var selectedItem: (block: String, className: String) = ("","")
    
    private var internalCellColor: UIColor = UIColor(red: (225.0/255.0), green: (238.0/255.0), blue: (254.0/255.0), alpha: 1.0)
    
    override func viewDidLoad() {
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections, always 1.
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section, the number of items in the schedule.
        return substitutions.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomizationCell", for: indexPath) 
        let item = substitutions[indexPath.row]
        
        // Configure the cell.
        if let blockLabel = cell.viewWithTag(501) as? UILabel {
            blockLabel.text = item.block
        }
        if let classLabel = cell.viewWithTag(502) as? UILabel {
            classLabel.text = item.className
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //Fixes background color on iPad.
        cell.backgroundColor = internalCellColor
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            substitutions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            SubstitutionManager.saveSubstitutions(substitutions)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let substitution: (block: String, className: String) = substitutions[indexPath.row]
        selectedItem = substitution
        selectedNum = indexPath.row
        
        self.performSegue(withIdentifier: "subDetail", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newSub = segue.destination as? NewSubViewController {
            if (segue.identifier == "subDetail") {
                newSub.editSubstitution(selectedItem)
            } else if (segue.identifier == "newSub") {
                newSub.newSubstitution()
            }
        }
    }
    
    func addSubstitution(_ sub: (block: String, className: String)) {
        substitutions.append(sub)
        substitutionsChanged()
    }
    func updateSubstitution(_ sub: (block: String, className: String)) {
        substitutions[selectedNum] = sub
        substitutionsChanged()
    }
    private func substitutionsChanged() {
        substitutions.sort(by: { $0.block < $1.block })
        SubstitutionManager.saveSubstitutions(substitutions)
        self.tableView.reloadData()
    }
}
