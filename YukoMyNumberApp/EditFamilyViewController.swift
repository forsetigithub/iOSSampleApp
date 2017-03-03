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
  
  fileprivate let realm = try! Realm()
  fileprivate let Properties = YukoMyNumberAppProperties.sharedInstance
  
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
    
    self.RegsiterButton.addTarget(self, action: #selector(EditFamilyViewController.tapGetMyNumber(_:)), for: UIControlEvents.touchUpInside)
    self.RegsiterButton.setTitle(Properties.ButtonTitles["RegisterMyNumber"], for: UIControlState())
    
    self.DeleteFamilyButton.addTarget(self, action: #selector(EditFamilyViewController.tapDeleteBtn(_:)), for: UIControlEvents.touchUpInside)
    self.DeleteFamilyButton.setTitle(Properties.ButtonTitles["DeleteData"], for: UIControlState())
  }
  
  override func viewWillAppear(_ animated: Bool) {

    FamilyNameTextField.text = self.FamilyItemData.FamilyName
    FirstNameTextField.text = self.FamilyItemData.FirstName
    RelationNameLabel.text = self.FamilyItemData.RSName
    
    if(FamilyItemData.MyNumberCheckDigitResult){
      MyNumberGetStateLabel.text = "取得済"
      MyNumberGetStateLabel.textColor = UIColor.lightGray
    }else{
      MyNumberGetStateLabel.text = "未取得"
      MyNumberGetStateLabel.textColor = UIColor.red
    }
    
    self.navigationController?.isToolbarHidden = true
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidDisappear(_ animated: Bool) {

  }
  override func viewWillDisappear(_ animated: Bool) {
    try! realm.write({ () -> Void in
      FamilyItemData.FamilyName = FamilyNameTextField.text!
      FamilyItemData.FirstName =  FirstNameTextField.text!
    
    })
  }
  
  func tapSaveButton(_ sender:UIBarButtonItem){

  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
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
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if(segue.identifier == "showModifyRelation"){
      let dest = segue.destination as! ModifyRelationViewController
      dest.FamilyItemData = self.FamilyItemData
    }
    
    if(segue.identifier == "showGetFamilyMyNumber"){
      
      let dest = segue.destination as! GetMyNumberViewController
      
      dest.MyNumberEditData = self.FamilyItemData
    }
  }
  
  @IBAction func tapGetMyNumber(_ sender: UIButton) {
    performSegue(withIdentifier: "showGetFamilyMyNumber", sender: self)
  }
  
  @IBAction func tapDeleteBtn(_ sender: AnyObject) {
    let alertProp = Properties.AlertMessages["DeleteExclamation"] as! [String:String]
    let deleteName = FamilyNameTextField.text! + "　" + FirstNameTextField.text!
    let myAlert:UIAlertController = UIAlertController(title: alertProp["Title"], message: "「\(deleteName) 」を\(alertProp["Message"]!)", preferredStyle: UIAlertControllerStyle.actionSheet)
    
    let OkAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action:UIAlertAction) -> Void in
      try! self.realm.write({ () -> Void in
        
        self.FamilyItemData.DeleteFlag = true
        
        self.navigationController?.popViewController(animated: true)
      })
    }
    
    let CancelAction = UIAlertAction(title: Properties.AlertMessages["Cancel"] as? String, style: UIAlertActionStyle.cancel) { (action:UIAlertAction) -> Void in
      
    }
  
    myAlert.addAction(OkAction)
    myAlert.addAction(CancelAction)
    
    present(myAlert, animated: true, completion: nil)
  }
}
