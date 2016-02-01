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
  
  private let realm = try! Realm()
  private let Properties = YukoMyNumberAppProperties.sharedInstance

  private var employeeeditdata:EmployeeData = EmployeeData()
  
  var EmployeeEditData:EmployeeData {
    set(newValue){
      employeeeditdata = newValue
    }
    get{
      return employeeeditdata
    }
  }
  
  @IBOutlet weak var FamilyNameTextField: UITextField!
  @IBOutlet weak var FirstNameTextField: UITextField!
  @IBOutlet weak var RelationName: UILabel!
  @IBOutlet weak var RelationPickerCell: UITableViewCell!
  @IBOutlet weak var RelationPickerView: UIPickerView!
  @IBOutlet weak var RegisterButton: UIButton!
  
  
  private let RelationPicker:RelationPickerViewController = RelationPickerViewController()
  
  // MARK: - Table View
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    self.FamilyNameTextField.delegate = self
    self.FirstNameTextField.delegate = self
    self.RelationPickerView.delegate = RelationPicker
    
    self.navigationItem.title = Properties.NavigationTitles["RegisterFamilyViewController"]
    self.FamilyNameTextField.placeholder = Properties.LabelItems["FamilyName"]
    self.FirstNameTextField.placeholder = Properties.LabelItems["FirstName"]
    
    RelationPicker.selectedRSCode = RelationPicker.pickerKeys[0]
    self.RelationName.text = RelationPicker.selectedRSName
    
    self.RegisterButton.addTarget(self, action: "tapRegisterButton:", forControlEvents: UIControlEvents.TouchUpInside)
    self.RegisterButton.setTitle(Properties.ButtonTitles["Register"], forState: UIControlState.Normal)
    
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
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
    let str = textField.text! + string
    
    switch (textField.tag) {
      case 1,2:
        if(str.characters.count > YukoMyNumberAppProperties.sharedInstance.EmployeeNameCharactersCount){
          return false
        }
        break
      default:
        break
    }
    
    return true
  }
  
  
  @IBAction func tapRegisterButton(sender: AnyObject) {
    
    var alertProp:[String:String] = [String:String]()
    
    //必須項目チェック
    if(self.FamilyNameTextField.text?.stringByReplacingOccurrencesOfString(" ", withString: "").isEmpty == true ||
      self.FirstNameTextField.text?.stringByReplacingOccurrencesOfString(" ", withString: "").isEmpty == true ||
      self.RelationName.text == RelationPicker.pickerValues[0]){
        
        alertProp = Properties.AlertMessages["RequiredItemValidError"] as! [String:String]
        
        let myAlert = UIAlertController(title: alertProp["Title"], message: alertProp["Message"], preferredStyle: UIAlertControllerStyle.Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
          
        })
        
        myAlert.addAction(OKAction)
        
        presentViewController(myAlert, animated: true, completion: nil)
        
        return
    }
    
    //続柄重複エラーチェック
    let rscodecheck = realm.objects(EmployeeData).filter("EmployeeCode = '\(self.EmployeeEditData.EmployeeCode)' and RSCode = '\(RelationPicker.selectedRSCode)'")
    
    if(rscodecheck.count != 0){
      
      alertProp = Properties.AlertMessages["DoubleCheckError"] as! [String:String]
      
      let myAlert = UIAlertController(title: alertProp["Title"], message: "「\(self.RelationName.text!)」は\(alertProp["Message"])", preferredStyle: UIAlertControllerStyle.Alert)
      
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
      family.EmployeeCode = employeeeditdata.EmployeeCode
      family.JoinedDate = employeeeditdata.JoinedDate
      
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