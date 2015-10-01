//
//  NewSubViewController.swift
//  X Schedule
//
//  Created by Nicholas Reichert on 6/14/15.
//  Copyright (c) 2015 Nicholas Reichert.
//

import UIKit
import XScheduleKit

class NewSubViewController: UITableViewController {
    
    @IBOutlet weak var blockName: UITextField!
    @IBOutlet weak var className: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var blockNameDelegate: BlockNameDelegate!
    var classNameDelegate: ClassNameDelegate!
    
    var substitution: (block: String, className: String) = ("","")
    enum SubstitutionMethod {
        case New
        case Edit
    }
    var subMethod: SubstitutionMethod = .New
    
    private var internalCellColor: UIColor = UIColor(red: (225.0/255.0), green: (238.0/255.0), blue: (254.0/255.0), alpha: 1.0)
    
    override func viewDidLoad() {
        blockNameDelegate = BlockNameDelegate(parent: self)
        classNameDelegate = ClassNameDelegate(parent: self)
        blockName.delegate = blockNameDelegate
        className.delegate = classNameDelegate
        setUpTitle()
        displaySubstitution()
        blockNameValueChanged(self)
        blockName.becomeFirstResponder()
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
        }
        
        //Goes back to the substitutions view.
        self.navigationController!.popViewControllerAnimated(true)
    }
    private func backOneViewController() -> UIViewController? {
        var parent: UIViewController?
        let controllersCount: Int = self.navigationController!.viewControllers.count
        parent = self.navigationController?.viewControllers[controllersCount-2]
        
        return parent
    }
    private func moveEditsToSub() {
        substitution.block = blockName.text!
        substitution.className = className.text!
    }
    
    @IBAction func blockNameValueChanged(sender: AnyObject) {
        if (blockName.text == "") {
            saveButton.enabled = false
        } else {
            saveButton.enabled = true
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //Fixes background color on iPad.
        cell.backgroundColor = internalCellColor
    }
    
}
class BlockNameDelegate: NSObject, UITextFieldDelegate {
    weak var parent: NewSubViewController!
    init(parent: NewSubViewController) {
        self.parent = parent
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        parent.className.becomeFirstResponder()
        return true
    }
}
class ClassNameDelegate: NSObject, UITextFieldDelegate {
    weak var parent: NewSubViewController!
    init(parent: NewSubViewController) {
        self.parent = parent
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        parent.saveButton(self)
        return true
    }
}
