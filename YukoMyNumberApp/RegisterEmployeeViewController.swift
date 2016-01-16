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
  
  let realm = try! Realm()
  
  // MARK: - Table View  
  @IBOutlet weak var EmployeeCode: UITextField!
  @IBOutlet weak var EmployeeFamilyName: UITextField!
  @IBOutlet weak var EmployeeFirstName: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    EmployeeCode.delegate = self
    EmployeeFamilyName.delegate = self
    EmployeeFirstName.delegate = self
    
    self.navigationItem.title = "新規登録"
    

  }
  
  override func viewDidAppear(animated: Bool) {
    self.EmployeeCode.becomeFirstResponder()
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

  
  @IBAction func tapRegisterButton(sender: UIButton) {
    try! realm.write({ () -> Void in
      let NewEmployeeData = EmployeeData()
      NewEmployeeData.EmployeeCode = self.EmployeeCode.text!
      NewEmployeeData.FamilyName = self.EmployeeFamilyName.text!
      NewEmployeeData.FirstName = self.EmployeeFirstName.text!
      NewEmployeeData.FamilySeqNo = 0
      NewEmployeeData.RSCode = "00"
      NewEmployeeData.CreateDateTime = NSDate()
      self.realm.add(NewEmployeeData)
      
      self.performSegueWithIdentifier("showRegisterList", sender: self)
    })
  
  }

  @IBAction func tapCancelButton(sender: UIBarButtonItem) {
     self.performSegueWithIdentifier("showRegisterList", sender: self)
  }
  
}