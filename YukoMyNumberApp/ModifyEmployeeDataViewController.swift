//
//  ModifyEmployeeData.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/12.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ModifyEmployeeDataViewController: UITableViewController,UITextFieldDelegate {
  
  
  let realm = try! Realm()
  
  enum ModifyModeEnum{
    case Employee
    case Name
  }
  
  var EmployeeEditData:EmployeeData = EmployeeData()
  var ModifyMode:ModifyModeEnum = ModifyModeEnum.Employee
  
  @IBOutlet weak var EmployeeCodeTextField: UITextField!
  @IBOutlet weak var FamilyNameTextField: UITextField!
  @IBOutlet weak var FirstNameTextField: UITextField!
  
  // MARK: - Table View
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    self.EmployeeCodeTextField.text = EmployeeEditData.EmployeeCode
    self.FamilyNameTextField.text = EmployeeEditData.EmployeeFamilyName
    self.FirstNameTextField.text = EmployeeEditData.EmployeeFirstName
    
    if(ModifyMode == ModifyModeEnum.Employee){
      self.FamilyNameTextField.enabled = false
      self.FirstNameTextField.enabled = false
      changeTextColor(FamilyNameTextField)
      changeTextColor(FirstNameTextField)

    }else{
      self.EmployeeCodeTextField.enabled = false
      changeTextColor(EmployeeCodeTextField)
    }
  }
  
  func changeTextColor(textField:UITextField){
    textField.textColor = UIColor.lightGrayColor()
  }
  
  @IBAction func tapSaveButton(sender: UIBarButtonItem) {
    try! realm.write({ () -> Void in
      EmployeeEditData.EmployeeCode = self.EmployeeCodeTextField.text!
      EmployeeEditData.EmployeeFamilyName = self.FamilyNameTextField.text!
      EmployeeEditData.EmployeeFirstName = self.FirstNameTextField.text!
      
      self.navigationController?.popViewControllerAnimated(true)
    })
  }
  
}
