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
  
  // MARK: - Table View
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    self.EmployeeCode.text = self.EmployeeEditData.EmployeeCode
    self.EmployeeName.text = self.EmployeeEditData.EmployeeName
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
}
