//
//  RegisterAddNewViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/06.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import UIKit
import RealmSwift

class RegisterEmployeeViewController : UITableViewController,UITextFieldDelegate {
  
  @IBOutlet weak var EmployeeCode: UITextField!
  @IBOutlet weak var EmployeeFamilyName: UITextField!
  @IBOutlet weak var EmployeeFirstName: UITextField!
  
  let realm = try! Realm()
  
  // MARK: - Table View
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    EmployeeCode.delegate = self
    EmployeeFamilyName.delegate = self
    EmployeeFirstName.delegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func textFieldDidEndEditing(textField: UITextField) {

  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }

  @IBAction func tapSaveButton(sender: UIBarButtonItem) {
    
    try! realm.write({ () -> Void in
      let NewEmployeeData = EmployeeData()
      NewEmployeeData.EmployeeCode = self.EmployeeCode.text!
      NewEmployeeData.EmployeeName = self.EmployeeFamilyName.text! + "　" + self.EmployeeFirstName.text!
      NewEmployeeData.CreateDateTime = NSDate()
      self.realm.add(NewEmployeeData)
      
  self.performSegueWithIdentifier("showRegisterList", sender: self)
    })
    
  }
  
  @IBAction func tapCancelButton(sender: UIBarButtonItem) {
  
    self.performSegueWithIdentifier("showRegisterList", sender: self)
  }
  
}