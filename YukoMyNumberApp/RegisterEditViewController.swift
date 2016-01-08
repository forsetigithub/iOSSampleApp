//
//  RegisterEditViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/05.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import UIKit

class RegisterEditViewController:UITableViewController{
  
  var EmployeeEditData = EmployeeData()
  
  @IBOutlet weak var EmployeeCode: UITextField!
  @IBOutlet weak var EmployeeName: UITextField!
  @IBOutlet weak var EmployeeMN: UITextField!
  
  // MARK: - Table View
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    loadEmployeeData()
    
  }
  
  func loadEmployeeData(){
    self.EmployeeCode.text = self.EmployeeEditData.EmployeeCode
    self.EmployeeName.text = self.EmployeeEditData.EmployeeName
    
    if(self.EmployeeEditData.EmployeeMN.characters.count == 12){
      self.EmployeeMN.text = "登録済"
      self.EmployeeMN.textColor = UIColor.blueColor()
    }else{
      self.EmployeeMN.text = "未登録"
      self.EmployeeMN.textColor = UIColor.redColor()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
}
