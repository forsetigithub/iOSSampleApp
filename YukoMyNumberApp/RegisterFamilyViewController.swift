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
                                    UIPickerViewDelegate {
  
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
  @IBOutlet weak var RelationName: UILabel!
  @IBOutlet weak var RelationPickerCell: UITableViewCell!
  @IBOutlet weak var RelationPickerView: UIPickerView!
  
  
  private let RelationPicker:RelationPickerViewController = RelationPickerViewController()
  
  // MARK: - Table View
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    self.FamilyNameTextField.delegate = self
    self.FirstNameTextField.delegate = self
  
    self.RelationPickerView.delegate = RelationPicker
    
    RelationPicker.selectedRSCode = RelationPicker.pickerKeys[0]
    self.RelationName.text = RelationPicker.selectedRSName
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePickerValue:", name: "updatePickerNotification", object: nil)

  }
  
  override func viewWillAppear(animated: Bool) {
    self.navigationController?.toolbarHidden = true
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
  
  
  
  @IBAction func tapRegisterButton(sender: AnyObject) {
    
    //必須項目チェック
    if(self.FamilyNameTextField.text?.characters.count == 0 ||
      self.FirstNameTextField.text?.characters.count == 0 ||
      self.RelationName.text == RelationPicker.pickerValues[0]){
        
        let myAlert = UIAlertController(title: "登録できません", message: "入力されていない項目があります。", preferredStyle: UIAlertControllerStyle.Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
          
        })
        
        myAlert.addAction(OKAction)
        
        presentViewController(myAlert, animated: true, completion: nil)
        
        return
    }
    
    //続柄重複エラーチェック
    let rscodecheck = realm.objects(EmployeeData).filter("EmployeeCode = '\(self.EmployeeEditData.EmployeeCode)' and RSCode = '\(RelationPicker.selectedRSCode)'")
    
    if(rscodecheck.count != 0){
      
      let myAlert = UIAlertController(title: "登録できません", message: "「\(self.RelationName.text!)」はすでに登録されています。", preferredStyle: UIAlertControllerStyle.Alert)
      
      let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
        
        
        
      })
      
      myAlert.addAction(OKAction)
      
      presentViewController(myAlert, animated: true, completion: nil)
    
      return
      
    }
  
    try! realm.write({ () -> Void in
      let family = EmployeeData()
      family.FamilyName = self.FamilyNameTextField.text!
      family.FirstName = self.FirstNameTextField.text!
      family.RSCode = RelationPicker.selectedRSCode
      family.EmployeeCode = eployeeeditdata.EmployeeCode
      
      family.FamilySeqNo = (realm.objects(EmployeeData).filter("EmployeeCode = '\(family.EmployeeCode)'").sorted("FamilySeqNo",
        ascending: true).first?.FamilySeqNo)! + 1
      
      realm.add(family)
      
      self.navigationController?.popViewControllerAnimated(true)
      
    })
    
  }

  func updatePickerValue(notification:NSNotification?){
    if(notification?.name == "updatePickerNotification"){
      self.RelationName.text = RelationPicker.pickerValues[RelationPicker.selectedPickerRow]
    }
  }

}