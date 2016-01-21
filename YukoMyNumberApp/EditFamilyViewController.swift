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
  
  var FamilyItemData:EmployeeData = EmployeeData()
  
  @IBOutlet weak var FamilyNameTextField: UITextField!
  @IBOutlet weak var FirstNameTextField: UITextField!
  @IBOutlet weak var RelationNameLabel: UILabel!
  @IBOutlet weak var MyNumberGetStateLabel: UILabel!

  
  let pickerItems:[String:String] = YukoMyNumberAppProperties.sharedInstance.RelationItems
  var pickerKeys:[String] = [String]()
  var pickerValues:[String] = [String]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "家族情報を編集"

    FamilyNameTextField.delegate = self
    FirstNameTextField.delegate = self
    
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
    let deleteName = FamilyNameTextField.text! + "　" + FirstNameTextField.text!
    let myAlert:UIAlertController = UIAlertController(title: "確認", message: "「\(deleteName) 」を削除します。\nよろしいですか？", preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    let OkAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
      try! self.realm.write({ () -> Void in
        
        self.FamilyItemData.DeleteFlag = true
        
        self.navigationController?.popViewControllerAnimated(true)
      })
    }
    
    let CancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action:UIAlertAction) -> Void in
      
    }
  
    myAlert.addAction(OkAction)
    myAlert.addAction(CancelAction)
    
    presentViewController(myAlert, animated: true, completion: nil)
  }
}
