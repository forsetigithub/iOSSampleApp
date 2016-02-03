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
  
  private let realm = try! Realm()
  private let Properties = YukoMyNumberAppProperties.sharedInstance
  
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
    
    EmployeeCodeTextField.placeholder = Properties.LabelItems["EmployeeCode"]
    FamilyNameTextField.placeholder = Properties.LabelItems["FamilyName"]
    FirstNameTextField.placeholder = Properties.LabelItems["FirstName"]
    
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
    
    if(self.EmployeeCodeTextField.text?.isEmpty == false &&
      self.FamilyNameTextField.text?.isEmpty == false &&
      self.FirstNameTextField.text?.isEmpty == false &&
      realm.objects(EmployeeData).filter("EmployeeCode = '\(self.EmployeeCodeTextField.text!)'").count == 0){
      
        try! realm.write({ () -> Void in
        EmployeeEditData.EmployeeCode = self.EmployeeCodeTextField.text!
        EmployeeEditData.FamilyName = self.FamilyNameTextField.text!
        EmployeeEditData.FirstName = self.FirstNameTextField.text!
      })

    }

  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
    let str = textField.text! + string
    
    switch textField.tag{
      case 1:
        if(str.characters.count > YukoMyNumberAppProperties.sharedInstance.EmployeeCodeCharactersCount){
          
          return false
        }else if(str.characters.count == YukoMyNumberAppProperties.sharedInstance.EmployeeCodeCharactersCount){
          if(realm.objects(EmployeeData).filter("EmployeeCode = '\(str)' and EmployeeCode !='\(self.EmployeeCodeTextField.text!)'").count != 0){
            
            let doubleerror:[String:String] = Properties.AlertMessages["DoubleCheckError"] as! [String:String]
            
            let myAlert = UIAlertController(title: doubleerror["Title"]!, message: "「\(str)」は\(doubleerror["Message"]!)", preferredStyle: UIAlertControllerStyle.Alert)
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            myAlert.addAction(OKAction)
            self.presentViewController(myAlert, animated: true, completion: nil)
          }
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
  
  func textFieldShouldEndEditing(textField: UITextField) -> Bool {
    
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
