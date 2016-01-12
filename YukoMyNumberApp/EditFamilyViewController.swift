//
//  EditFamilyViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/11.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class EditFamilyViewController:UITableViewController,UITextFieldDelegate {
  
  let realm = try! Realm()
  
  var FamilyItemData:EmployeeFamilyData = EmployeeFamilyData()
  
  @IBOutlet weak var FamilyNameTextField: UITextField!
  @IBOutlet weak var FirstNameTextField: UITextField!
  @IBOutlet weak var RelationNameLabel: UILabel!

  let pickerItems:[String:String] = YukoMyNumberAppProperties.sharedInstance.RelationItems
  var pickerKeys:[String] = [String]()
  var pickerValues:[String] = [String]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "家族情報編集"
    let saveButton = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Plain, target: self, action: "tapSaveButton:")
    self.navigationItem.rightBarButtonItem = saveButton
    
    FamilyNameTextField.delegate = self
    FirstNameTextField.delegate = self
    
  }
  
  override func viewWillAppear(animated: Bool) {

    FamilyNameTextField.text = self.FamilyItemData.FamilyName
    FirstNameTextField.text = self.FamilyItemData.FirstName
    RelationNameLabel.text = self.FamilyItemData.RSName
  
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func tapSaveButton(sender:UIBarButtonItem){
    try! realm.write({ () -> Void in
      FamilyItemData.FamilyName = FamilyNameTextField.text!
      FamilyItemData.FirstName =  FirstNameTextField.text!
      self.navigationController?.popViewControllerAnimated(true)
    })
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
  
  @IBAction func tapGetMyNumber(sender: UIButton) {
    performSegueWithIdentifier("showGetFamilyMyNumber", sender: self)
  
  }
  
}
