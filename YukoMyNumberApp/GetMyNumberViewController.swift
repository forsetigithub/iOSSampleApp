//
//  GetMyNumberTest.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/08.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import SVProgressHUD
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class GetMyNumberViewController : UITableViewController,UITextFieldDelegate{
  
  @IBOutlet weak var MyNumberTextField: UITextField!
  @IBOutlet weak var showMyNumberLabel: UILabel!
  @IBOutlet weak var subjectName: UILabel!
  @IBOutlet weak var showMyNumberSwitch: UISwitch!
  @IBOutlet weak var registerButton: UIButton!
  @IBOutlet weak var deleteMyNumberButton: UIButton!
  
  
  fileprivate let realm = try! Realm()
  fileprivate let Properties = YukoMyNumberAppProperties.sharedInstance
  
  var MyNumberEditData:EmployeeData = EmployeeData()
  
  fileprivate var previousTextFieldContent:String?
  fileprivate var previousSelection:UITextRange?

  // MARK: - Table View
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.MyNumberTextField.delegate = self
    self.title = "\(Properties.LabelItems["MyNumber"]!)\(Properties.ButtonTitles["Register"]!)"
    self.MyNumberTextField.placeholder = Properties.LabelItems["MyNumber"]
    
    self.subjectName.text = MyNumberEditData.FamilyName + "　" + MyNumberEditData.FirstName
    
    self.MyNumberTextField.addTarget(self, action: #selector(GetMyNumberViewController.reformatAsAddSpaceNumber(_:)), for: UIControl.Event.editingChanged)
    
    self.registerButton.addTarget(self, action: #selector(GetMyNumberViewController.tapRegisterButton(_:)), for: UIControl.Event.touchUpInside)
    self.registerButton.setTitle(Properties.ButtonTitles["Register"], for: UIControl.State())
    
    self.deleteMyNumberButton.addTarget(self, action: #selector(GetMyNumberViewController.tapDeleteMyNumber(_:)), for: UIControl.Event.touchUpInside)
    self.deleteMyNumberButton.setTitle(Properties.ButtonTitles["DeleteMyNumber"], for: UIControl.State())
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if(MyNumberEditData.MyNumberCheckDigitResult){
      self.showMyNumberSwitch.isOn = false
    }else{
      self.showMyNumberSwitch.isOn = true
    }
    
    self.MyNumberTextField.text = MyNumberEditData.MyNumber
    changeShowMyNumberSwitch(showMyNumberSwitch)
    
    self.navigationController?.isToolbarHidden = true

  }
  
  override func viewDidAppear(_ animated: Bool) {
    if(self.MyNumberTextField.text?.isEmpty == true){
      self.MyNumberTextField.becomeFirstResponder()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
    self.previousTextFieldContent = textField.text
    self.previousSelection = textField.selectedTextRange
    
    return true

  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    return true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
  

  }
  
  // MARK: MyNumberTextFieldFormatt
  /* 
  * 番号4桁ごとにスペースを挿入する
  */
  @objc func reformatAsAddSpaceNumber(_ textField:UITextField){

    var targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: (textField.selectedTextRange?.start)!)
    
    let NumberWithoutSpaces = textField.text?.replacingOccurrences(of: " ", with: "")
    
    if(NumberWithoutSpaces?.characters.count > (Properties.MyNumberCharactersCount) as Int){
      textField.text = previousTextFieldContent
      textField.selectedTextRange = previousSelection
      return
    }
    
    let NumberWithSpaces = insertSpacesEveryFourDigitsIntoString(NumberWithoutSpaces!, CursorPosition: &targetCursorPosition)
    textField.text = NumberWithSpaces
    
    let targetPosition = textField.position(from: textField.beginningOfDocument, in: UITextLayoutDirection.right,offset: targetCursorPosition)
    textField.selectedTextRange = textField.textRange(from: targetPosition!, to: targetPosition!)
  }
  
  fileprivate func insertSpacesEveryFourDigitsIntoString(_ string:String,CursorPosition cursorPosition:inout Int) -> String{
    
    var stringWithAddedSpaces:String = ""
    let cursorPositionInSpacelessString = cursorPosition
    
    for i in 0 ..< string.characters.count {
      if((i > 0) && ((i % 4) == 0)){
        stringWithAddedSpaces = stringWithAddedSpaces + " "
        if(i < cursorPositionInSpacelessString){
          cursorPosition += 1
        }
      }
      let range = NSRange(location: i, length: 1)
      stringWithAddedSpaces = stringWithAddedSpaces + ((string as NSString).substring(with: range))
    }
    
    return stringWithAddedSpaces
  }
  
  @IBAction func changeShowMyNumberSwitch(_ sender: UISwitch) {
    
    self.MyNumberTextField.resignFirstResponder()
    
    if(sender.isOn){
      self.showMyNumberLabel.text = "表示"
      self.MyNumberTextField.isSecureTextEntry = false
    }else{
      self.showMyNumberLabel.text = "非表示"
      self.MyNumberTextField.isSecureTextEntry = true
    }
  
  }

  @IBAction func tapRegisterButton(_ sender: UIButton) {
    
    let inputMyNumber:String = self.MyNumberTextField.text!
    
    //チェックデジット
    if((inputMyNumber.isValidMyNumber()) == false){
      
      let myAlert:UIAlertController = UIAlertController(title: "マイナンバー入力エラー", message: "マイナンバーが未入力もしくは入力に\n誤りがあります。", preferredStyle: UIAlertController.Style.alert)
      
      let OKAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: { (action:UIAlertAction) -> Void in
        
      })
      
      myAlert.addAction(OKAction)
      present(myAlert, animated: true, completion: nil)
      return
    
    }
    
    //重複チェック
    let result = realm.objects(EmployeeData.self).filter("MyNumber = '\(inputMyNumber)'")
    if(result.count != 0){
      let myAlert = UIAlertController(title: "マイナンバー入力エラー", message: "入力したマイナンバーはすでに登録されています。", preferredStyle: UIAlertController.Style.alert)
      let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: nil)
      
      myAlert.addAction(OKAction)
      
      present(myAlert,animated: true,completion: nil)
      return
    }


    try! realm.write { () -> Void in
      
      let result = realm.objects(EmployeeData.self).filter("EmployeeCode = '\(MyNumberEditData.EmployeeCode)'" +
        " and RSCode = '\(MyNumberEditData.RSCode)'")

      if(result.count == 1){
        
        result[0].MyNumber = self.MyNumberTextField.text!
        
        self.navigationController?.popViewController(animated: true)
        
      }else{
        let myAlert:UIAlertController = UIAlertController(title: "エラー", message: "同じ続柄がすでに登録されているため、マイナンバーを登録できません！", preferredStyle: UIAlertController.Style.alert)
        
        let OKAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: { (action:UIAlertAction) -> Void in

          self.MyNumberTextField.resignFirstResponder()
          
        })
        
        myAlert.addAction(OKAction)
        
        present(myAlert, animated: true, completion: nil)
      }
    }
  }
  
  @objc func tapDeleteMyNumber(_ sender:UIButton){
    let deleteProp = Properties.AlertMessages["DeleteExclamation"] as! [String:String]
    
    let myAlert = UIAlertController(title: deleteProp["Title"], message:"\(Properties.LabelItems["MyNumber"]!)を\(deleteProp["Message"]!)", preferredStyle: UIAlertController.Style.alert)
    let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (action:UIAlertAction) -> Void in
      try! self.realm.write({ () -> Void in
        self.MyNumberEditData.MyNumber = ""
        
        self.navigationController?.popViewController(animated: true)
      })
    }
    
    let CancelAction = UIAlertAction(title: Properties.AlertMessages["Cancel"] as? String, style: UIAlertAction.Style.cancel, handler: nil)
    
    myAlert.addAction(OKAction)
    myAlert.addAction(CancelAction)
    
    present(myAlert, animated: true, completion: nil)
  
  }
}
