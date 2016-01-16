//
//  RegisterFamilyViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/09.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import RealmSwift

class RegisterFamilyViewController : UITableViewController,UITextFieldDelegate,
                                    UIPickerViewDelegate,UIPickerViewDataSource {
  
  let realm = try! Realm()

  private var eployeeeditdata:EmployeeData = EmployeeData()
  
  var EmployeeEditData:EmployeeData {
    set(newValue){
      eployeeeditdata = newValue
    }
    get{
      return eployeeeditdata
    }
  }
  
  @IBOutlet weak var FamilyNameTextField: UITextField!
  @IBOutlet weak var FirstNameTextField: UITextField!
  @IBOutlet weak var RelationNamesPickerView: UIPickerView!
  @IBOutlet weak var RelationName: UILabel!
  
  private let pickerItems:[String:String] = YukoMyNumberAppProperties.sharedInstance.RelationItems

  var pickerKeys:[String] = [String]()
  var pickerValues:[String] = [String]()
  
  // MARK: - Table View
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    self.RelationNamesPickerView.delegate = self
    self.FamilyNameTextField.delegate = self
    self.FirstNameTextField.delegate = self
    
    pickerKeys = Array(pickerItems.values).sort()
    
    for pikcerkey in pickerKeys {
      for (key,val) in pickerItems{
        if(pikcerkey == val){
           pickerValues.append(key)
        }
      }
    }
    
    self.RelationName.text = pickerValues[0]

  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    self.FamilyNameTextField.becomeFirstResponder()
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    var height:CGFloat = YukoMyNumberAppProperties.sharedInstance.TableViewCellDefaultHeight
    if(indexPath.row == 3){
      height =  150
    }
    
    return height
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
  
  @IBAction func tapSaveButton(sender: UIBarButtonItem) {
    
    if(self.FamilyNameTextField.text?.characters.count == 0 ||
      self.FirstNameTextField.text?.characters.count == 0 ||
      self.RelationName.text == pickerValues[0]){
    
      //必須未入力エラー
    }
    
    try! realm.write({ () -> Void in
      let family = EmployeeData()
      family.FamilyName = self.FamilyNameTextField.text!
      family.FirstName = self.FirstNameTextField.text!
      family.RSName = self.RelationName.text!
      family.RSCode = self.pickerItems[self.RelationName.text!]!
      family.EmployeeCode = eployeeeditdata.EmployeeCode
      
      family.FamilySeqNo = (realm.objects(EmployeeData).filter("EmployeeCode = '\(family.EmployeeCode)'").sorted("FamilySeqNo",
        ascending: true).first?.FamilySeqNo)! + 1
      
      realm.add(family)
      
      self.navigationController?.popViewControllerAnimated(true)
      
    })
  }
  
  //MARK: UIPickerView
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerItems.count
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    
    return pickerValues[row] as String
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

    if(row != 0){
      self.RelationName.text = pickerValues[row]
    }
  }
}