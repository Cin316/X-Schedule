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
        case new
        case edit
    }
    var subMethod: SubstitutionMethod = .new
    
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
        if (subMethod == .new) {
            self.title = "New Substitution"
        } else if (subMethod == .edit) {
            self.title = "Edit Substitution"
        }
    }
    private func displaySubstitution() {
        blockName.text = substitution.block
        className.text = substitution.className
    }
    
    func newSubstitution() {
        substitution = ("","")
        subMethod = .new
    }
    func editSubstitution(_ sub: (block: String, className: String)) {
        substitution = sub
        subMethod = .edit
    }
    
    @IBAction func saveButton(_ sender: AnyObject) {
        moveEditsToSub()
        
        if let subList = backOneViewController() as? CustomizationViewController {
            if (subMethod == .new) {
                subList.addSubstitution(substitution)
            } else if (subMethod == .edit) {
                subList.updateSubstitution(substitution)
            }
        }
        
        //Goes back to the substitutions view.
        self.navigationController!.popViewController(animated: true)
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
    
    @IBAction func blockNameValueChanged(_ sender: AnyObject) {
        if (blockName.text == "") {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //Fixes background color on iPad.
        cell.backgroundColor = internalCellColor
    }
    
}
class BlockNameDelegate: NSObject, UITextFieldDelegate {
    weak var parent: NewSubViewController!
    init(parent: NewSubViewController) {
        self.parent = parent
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        parent.className.becomeFirstResponder()
        return true
    }
}
class ClassNameDelegate: NSObject, UITextFieldDelegate {
    weak var parent: NewSubViewController!
    init(parent: NewSubViewController) {
        self.parent = parent
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        parent.saveButton(self)
        return true
    }
}
