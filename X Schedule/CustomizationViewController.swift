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
    
    override func viewDidLoad() {
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections, always 1.
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section, the number of items in the schedule.
        return substitutions.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomizationCell", forIndexPath: indexPath) as! UITableViewCell
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell: UITableViewCell? = tableView.cellForRowAtIndexPath(indexPath)
        var substitution: (block: String, className: String) = substitutions[indexPath.row]
        selectedItem = substitution
        selectedNum = indexPath.row
        
        self.performSegueWithIdentifier("subDetail", sender: self)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let newSub = segue.destinationViewController as? NewSubViewController {
            if (segue.identifier == "subDetail") {
                newSub.editSubstitution(selectedItem)
            } else if (segue.identifier == "newSub") {
                newSub.newSubstitution()
            }
        }
    }
    
    func addSubstitution(sub: (block: String, className: String)) {
        substitutions.append(sub)
    }
    func updateSubstitution(sub: (block: String, className: String)) {
        substitutions[selectedNum] = sub
    }
}

class NewSubViewController: UITableViewController {

    @IBOutlet weak var blockName: UITextField!
    @IBOutlet weak var className: UITextField!
    
    var substitution: (block: String, className: String) = ("","")
    enum SubstitutionMethod {
        case New
        case Edit
    }
    var subMethod: SubstitutionMethod = .New
    
    override func viewDidLoad() {
        setUpTitle()
        displaySubstitution()
    }
    private func setUpTitle() {
        if (subMethod == .New) {
            self.title = "New Substitution"
        } else if (subMethod == .Edit) {
            self.title = "Edit Substitution"
        }
    }
    private func displaySubstitution() {
        blockName.text = substitution.block
        className.text = substitution.className
    }
    
    func newSubstitution() {
        substitution = ("","")
        subMethod = .New
    }
    func editSubstitution(sub: (block: String, className: String)) {
        substitution = sub
        subMethod = .Edit
    }
    
    @IBAction func saveButton(sender: AnyObject) {
        moveEditsToSub()
        
        if let subList = backOneViewController() as? CustomizationViewController {
            if (subMethod == .New) {
                subList.addSubstitution(substitution)
            } else if (subMethod == .Edit) {
                subList.updateSubstitution(substitution)
            }
            subList.tableView.reloadData()
        }
        
        //Goes back to the substitutions view.
        self.navigationController!.popViewControllerAnimated(true)
    }
    private func backOneViewController() -> UIViewController? {
        var parent: UIViewController?
        var controllersCount: Int = self.navigationController!.viewControllers!.count
        parent = self.navigationController?.viewControllers[controllersCount-2] as? UIViewController
        
        return parent
    }
    private func moveEditsToSub() {
        substitution.block = blockName.text
        substitution.className = className.text
    }
    
}
