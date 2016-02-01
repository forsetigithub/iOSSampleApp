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
  
  private let realm = try! Realm()
  private let Properties = YukoMyNumberAppProperties.sharedInstance
  
  var FamilyItemData:EmployeeData = EmployeeData()
  
  @IBOutlet weak var FamilyNameTextField: UITextField!
  @IBOutlet weak var FirstNameTextField: UITextField!
  @IBOutlet weak var RelationNameLabel: UILabel!
  @IBOutlet weak var MyNumberGetStateLabel: UILabel!
  @IBOutlet weak var RegsiterButton: UIButton!
  @IBOutlet weak var DeleteFamilyButton: UIButton!

  
  var pickerItems:[String:String] = [String:String]()
  var pickerKeys:[String] = [String]()
  var pickerValues:[String] = [String]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = Properties.NavigationTitles["EditFamilyViewController"]

    FamilyNameTextField.delegate = self
    FirstNameTextField.delegate = self
    pickerItems = Properties.RelationItems
    
    self.FamilyNameTextField.placeholder = Properties.LabelItems["FamilyName"]
    self.FirstNameTextField.placeholder = Properties.LabelItems["FirstName"]
    
    self.RegsiterButton.addTarget(self, action: "tapGetMyNumber:", forControlEvents: UIControlEvents.TouchUpInside)
    self.RegsiterButton.setTitle(Properties.ButtonTitles["RegisterMyNumber"], forState: UIControlState.Normal)
    
    self.DeleteFamilyButton.addTarget(self, action: "tapDeleteBtn:", forControlEvents: UIControlEvents.TouchUpInside)
    self.DeleteFamilyButton.setTitle(Properties.ButtonTitles["DeleteData"], forState: UIControlState.Normal)
  }
  
  override func viewWillAppear(animated: Bool) {

    FamilyNameTextField.text = self.FamilyItemData.FamilyName
    FirstNameTextField.text = self.FamilyItemData.FirstName
    RelationNameLabel.text = self.FamilyItemData.RSName
    
    if(FamilyItemData.MyNumberCheckDigitResult){
      MyNumberGetStateLabel.text = "取得済"
      MyNumberGetStateLabel.textColor = UIColor.lightGrayColor()
    }else{
      MyNumberGetStateLabel.text = "未取得"
      MyNumberGetStateLabel.textColor = UIColor.redColor()
    }
    
    self.navigationController?.toolbarHidden = true
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidDisappear(animated: Bool) {

  }
  override func viewWillDisappear(animated: Bool) {
    try! realm.write({ () -> Void in
      FamilyItemData.FamilyName = FamilyNameTextField.text!
      FamilyItemData.FirstName =  FirstNameTextField.text!
    
    })
  }
  
  func tapSaveButton(sender:UIBarButtonItem){

  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
    let str = textField.text! + string
    
    switch (textField.tag) {
    case 1,2:
      if(str.characters.count > Properties.EmployeeNameCharactersCount){
        return false
      }
      break
    default:
      break
    }
    
    return true
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if(segue.identifier == "showModifyRelation"){
      let dest = segue.destinationViewController as! ModifyRelationViewController
      dest.FamilyItemData = self.FamilyItemData
    }
    
    if(segue.identifier == "showGetFamilyMyNumber"){
      
      let dest = segue.destinationViewController as! GetMyNumberViewController
      
      dest.MyNumberEditData = self.FamilyItemData
    }
  }
  
  @IBAction func tapGetMyNumber(sender: UIButton) {
    performSegueWithIdentifier("showGetFamilyMyNumber", sender: self)
  }
  
  @IBAction func tapDeleteBtn(sender: AnyObject) {
    let alertProp = Properties.AlertMessages["DeleteExclamation"] as! [String:String]
    let deleteName = FamilyNameTextField.text! + "　" + FirstNameTextField.text!
    let myAlert:UIAlertController = UIAlertController(title: alertProp["Title"], message: "「\(deleteName) 」を\(alertProp["Message"]!)", preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    let OkAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
      try! self.realm.write({ () -> Void in
        
        self.FamilyItemData.DeleteFlag = true
        
        self.navigationController?.popViewControllerAnimated(true)
      })
    }
    
    let CancelAction = UIAlertAction(title: Properties.AlertMessages["Cancel"] as? String, style: UIAlertActionStyle.Cancel) { (action:UIAlertAction) -> Void in
      
    }
  
    myAlert.addAction(OkAction)
    myAlert.addAction(CancelAction)
    
    presentViewController(myAlert, animated: true, completion: nil)
  }
}
