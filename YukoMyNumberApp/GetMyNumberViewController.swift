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

class GetMyNumberViewController : UITableViewController,UITextFieldDelegate{
  
  @IBOutlet weak var MyNumberTextField: UITextField!
  @IBOutlet weak var showMyNumberLabel: UILabel!
  @IBOutlet weak var subjectName: UILabel!
  @IBOutlet weak var showMyNumberSwitch: UISwitch!
  
  private let realm = try! Realm()
  
  var MyNumberEditData:EmployeeData = EmployeeData()
  
  private var previousTextFieldContent:String?
  private var previousSelection:UITextRange?

  // MARK: - Table View
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.MyNumberTextField.delegate = self
    self.title = "\(YukoMyNumberAppProperties.sharedInstance.LabelItems["MyNumber"]!)\(YukoMyNumberAppProperties.sharedInstance.ButtonTitles["Register"])"
    
    self.subjectName.text = MyNumberEditData.FamilyName + "　" + MyNumberEditData.FirstName
    
    self.MyNumberTextField.addTarget(self, action: "reformatAsAddSpaceNumber:", forControlEvents: UIControlEvents.EditingChanged)
  }
  
  override func viewWillAppear(animated: Bool) {
    if(MyNumberEditData.MyNumberCheckDigitResult){
      self.showMyNumberSwitch.on = false
    }else{
      self.showMyNumberSwitch.on = true
    }
    
    self.MyNumberTextField.text = MyNumberEditData.MyNumber
    changeShowMyNumberSwitch(showMyNumberSwitch)
    
    self.navigationController?.toolbarHidden = true
  }
  
  override func viewDidAppear(animated: Bool) {
    self.MyNumberTextField.becomeFirstResponder()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
    self.previousTextFieldContent = textField.text
    self.previousSelection = textField.selectedTextRange
    
    return true

  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    return true
  }
  
  override func viewWillDisappear(animated: Bool) {
  

  }
  
  // MARK: MyNumberTextFieldFormatt
  /* 
  * 番号4桁ごとにスペースを挿入する
  */
  func reformatAsAddSpaceNumber(textField:UITextField){

    var targetCursorPosition = textField.offsetFromPosition(textField.beginningOfDocument, toPosition: (textField.selectedTextRange?.start)!)
    
    let NumberWithoutSpaces = textField.text?.stringByReplacingOccurrencesOfString(" ", withString: "")
    
    if(NumberWithoutSpaces?.characters.count > (YukoMyNumberAppProperties.sharedInstance.MyNumberCharactersCount) as Int){
      textField.text = previousTextFieldContent
      textField.selectedTextRange = previousSelection
      return
    }
    
    let NumberWithSpaces = insertSpacesEveryFourDigitsIntoString(NumberWithoutSpaces!, CursorPosition: &targetCursorPosition)
    textField.text = NumberWithSpaces
    
    let targetPosition = textField.positionFromPosition(textField.beginningOfDocument, inDirection: UITextLayoutDirection.Right,offset: targetCursorPosition)
    textField.selectedTextRange = textField.textRangeFromPosition(targetPosition!, toPosition: targetPosition!)
  }
  
  private func insertSpacesEveryFourDigitsIntoString(string:String,inout CursorPosition cursorPosition:Int) -> String{
    
    var stringWithAddedSpaces:String = ""
    let cursorPositionInSpacelessString = cursorPosition
    
    for (var i = 0; i < string.characters.count;i++){
      if((i > 0) && ((i % 4) == 0)){
        stringWithAddedSpaces = stringWithAddedSpaces + " "
        if(i < cursorPositionInSpacelessString){
          cursorPosition++
        }
      }
      let range = NSRange(location: i, length: 1)
      stringWithAddedSpaces = stringWithAddedSpaces + ((string as NSString).substringWithRange(range))
    }
    
    return stringWithAddedSpaces
  }
  
  @IBAction func changeShowMyNumberSwitch(sender: UISwitch) {
    
    self.MyNumberTextField.resignFirstResponder()
    
    if(sender.on){
      self.showMyNumberLabel.text = "表示"
      self.MyNumberTextField.secureTextEntry = false
    }else{
      self.showMyNumberLabel.text = "非表示"
      self.MyNumberTextField.secureTextEntry = true
    }
  
  }

  @IBAction func tapRegisterButton(sender: UIButton) {
    
    let inputMyNumber:String = self.MyNumberTextField.text!
    
    //チェックデジット
    if((inputMyNumber.isValidMyNumber()) == false){
      
      let myAlert:UIAlertController = UIAlertController(title: "マイナンバー入力エラー", message: "マイナンバーが未入力もしくは入力に誤りがあります。", preferredStyle: UIAlertControllerStyle.Alert)
      
      let OKAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
        
      })
      
      myAlert.addAction(OKAction)
      presentViewController(myAlert, animated: true, completion: nil)
      return
    
    }
    
    //重複チェック
#if DEBUG
#else
  
    let result = realm.objects(EmployeeData).filter("MyNumber = '\(inputMyNumber)'")
    if(result.count != 0){
      let myAlert = UIAlertController(title: "マイナンバー入力エラー", message: "入力したマイナンバーはすでに登録されています。", preferredStyle: UIAlertControllerStyle.Alert)
      let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
      
      myAlert.addAction(OKAction)
      
      presentViewController(myAlert,animated: true,completion: nil)
      return
    }
#endif

    try! realm.write { () -> Void in
      
      let result = realm.objects(EmployeeData).filter("EmployeeCode = '\(MyNumberEditData.EmployeeCode)'" +
        " and RSCode = '\(MyNumberEditData.RSCode)'")

      if(result.count == 1){
        
        result[0].MyNumber = self.MyNumberTextField.text!
        
        self.navigationController?.popViewControllerAnimated(true)
        
      }else{
        let myAlert:UIAlertController = UIAlertController(title: "エラー", message: "同じ続柄がすでに登録されているため、マイナンバーを登録できません！", preferredStyle: UIAlertControllerStyle.Alert)
        
        let OKAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
          
          self.MyNumberTextField.resignFirstResponder()
          
        })
        
        myAlert.addAction(OKAction)
        
        presentViewController(myAlert, animated: true, completion: nil)
      }
    }
  }
}