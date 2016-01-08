//
//  RegisterEditViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/05.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import UIKit

class RegisterEditViewController:UITableViewController{
  
  private var employeeeditdata:EmployeeData = EmployeeData()
  
  var EmployeeEditData:EmployeeData{
    set(newValue){
      employeeeditdata = newValue
    }
    get{
      return employeeeditdata
    }
  }
  
  @IBOutlet weak var EmployeeCodeTextField: UITextField!
  @IBOutlet weak var EmployeeNameTextField: UITextField!
  @IBOutlet weak var EmployeeMNTextField: UITextField!
  
  
  // MARK: - Table View
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    //loadEmployeeData()
    
  }
  
  override func viewWillAppear(animated: Bool) {
    loadEmployeeData()
  }
  
  
  func loadEmployeeData(){
    
    print(employeeeditdata.EmployeeMN)
    
    self.EmployeeCodeTextField.text = employeeeditdata.EmployeeCode
    self.EmployeeNameTextField.text = employeeeditdata.EmployeeName
    
    if(employeeeditdata.EmployeeMN.characters.count ==
      YukoMyNumberAppProperties.sharedInstance.MyNumberCharactersCount){
      
      self.EmployeeMNTextField.text = "登録済"
      self.EmployeeMNTextField.textColor = UIColor.blueColor()
    }else{
      self.EmployeeMNTextField.text = "未登録"
      self.EmployeeMNTextField.textColor = UIColor.redColor()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if(segue.identifier == "showGetMyNumber") {
      let dest = segue.destinationViewController as! GetMyNumberTestViewController
      dest.EmployeeEditData = employeeeditdata
    }
  }
  
  @IBAction func tapGetMyNumber(sender: UIButton) {
    performSegueWithIdentifier("showGetMyNumber", sender: self)
  
  }
  
  
}
