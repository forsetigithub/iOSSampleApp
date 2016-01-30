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
    EmployeeCodeTextField.delegate = self
    FamilyNameTextField.delegate = self
    FirstNameTextField.delegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewWillAppear(animated: Bool) {
    
    self.EmployeeCodeTextField.text = EmployeeEditData.EmployeeCode
    self.FamilyNameTextField.text = EmployeeEditData.FamilyName
    self.FirstNameTextField.text = EmployeeEditData.FirstName
    
    if(ModifyMode == ModifyModeEnum.Employee){
      changeTextAttribute(FamilyNameTextField)
      changeTextAttribute(FirstNameTextField)

    }else{
      changeTextAttribute(EmployeeCodeTextField)
    }
    
    self.navigationController?.toolbarHidden = true
  }
  
  override func viewWillDisappear(animated: Bool) {
    
    try! realm.write({ () -> Void in
      EmployeeEditData.EmployeeCode = self.EmployeeCodeTextField.text!
      EmployeeEditData.FamilyName = self.FamilyNameTextField.text!
      EmployeeEditData.FirstName = self.FirstNameTextField.text!
    })
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
    let str = textField.text! + string
    
    switch textField.tag{
      case 1:
        if(str.characters.count > YukoMyNumberAppProperties.sharedInstance.EmployeeCodeCharactersCount){
          return false
        }
        break
      case 2,3:
        if(str.characters.count > YukoMyNumberAppProperties.sharedInstance.EmployeeNameCharactersCount){
          return false
        }
        break
      default:
        break
    }
    
    return true
  }
  
  func changeTextAttribute(textField:UITextField){
    if let cell = textField.superview?.superview as? UITableViewCell{
      cell.userInteractionEnabled = false
    }
    
    textField.enabled = false
    textField.textColor = UIColor.lightGrayColor()
  }
  
}
