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
    
    @IBAction func blockNameValueChanged(sender: AnyObject) {
        if (blockName.text == "") {
            saveButton.enabled = false
        } else {
            saveButton.enabled = true
        }
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