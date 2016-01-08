//
//  GetMyNumberTest.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/08.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class GetMyNumberTestViewController : UIViewController,UITextFieldDelegate{
  
  @IBOutlet weak var MyNumberTextField: UITextField!
  
  let realm = try! Realm()
  
  private var employeeeditdata:EmployeeData = EmployeeData()
  
  var EmployeeEditData:EmployeeData{
    set(newValue){
      employeeeditdata = newValue
    }
    get{
      return employeeeditdata
    }
  }
  
  // MARK: - Table View
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.MyNumberTextField.delegate = self
    self.MyNumberTextField.text = employeeeditdata.EmployeeMN
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    return true
  }
  
  @IBAction func tapGetMyNumber(sender: UIButton) {
    
    self.MyNumberTextField.text = TestPropList.sharedInstance.TestMyNumber as? String

  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if(segue.identifier == "returnRegisterEdit") {
      
      try! realm.write { () -> Void in
        employeeeditdata.EmployeeMN = self.MyNumberTextField.text!
      }
      
      let dest = segue.destinationViewController as! RegisterEditViewController
      dest.EmployeeEditData = employeeeditdata
      
    }
  }
}