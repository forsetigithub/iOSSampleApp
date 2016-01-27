//
//  ChangePassCodeViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/23.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

enum CHANGEPASSCODEMODE{
  case NEW
  case MODIFY
}

class ChangePassCodeViewController:UITableViewController,UITextFieldDelegate{

  var EmployeeEditData:EmployeeData?
  
  private let realm = try! Realm()
  
  @IBOutlet weak var PassCodeBefore: UITextField!
  @IBOutlet weak var PassCodeAfter: UITextField!
  @IBOutlet weak var PassCodeAfterReEnter: UITextField!
  
  private var InputPassCode:String?
  
  private var changePassCodeMode:CHANGEPASSCODEMODE?
  private var buttontitle:String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.PassCodeBefore.delegate = self
    self.PassCodeAfter.delegate = self
    self.PassCodeAfterReEnter.delegate = self
   
    var title = "暗証番号を登録"
    buttontitle = "登録"
    changePassCodeMode = CHANGEPASSCODEMODE.NEW
    
    if(EmployeeEditData?.PassCode.characters.count != 0){
      title = "暗証番号を変更"
      buttontitle = "変更"
      changePassCodeMode = CHANGEPASSCODEMODE.MODIFY
    }
    self.navigationItem.title = title
    let saveButtonItem = UIBarButtonItem(title: buttontitle, style: UIBarButtonItemStyle.Done, target: self, action: "tapSavePassCodeButton:")
    self.navigationItem.rightBarButtonItem = saveButtonItem
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewWillAppear(animated: Bool) {
    self.navigationController?.toolbarHidden = true
    
    if(changePassCodeMode == CHANGEPASSCODEMODE.NEW){
      self.PassCodeBefore.placeholder = "暗証番号(\(YukoMyNumberAppProperties.sharedInstance.PassCodeCharactersCount)桁)"
      self.PassCodeAfter.placeholder = "暗証番号(再入力)"
      self.PassCodeAfterReEnter.hidden = true
      
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if(changePassCodeMode == CHANGEPASSCODEMODE.NEW){
      return 2
    }else{
      return 3
    }
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    //暗証番号の桁数しか入力できないようにする

    let str = textField.text! + string
    if(str.characters.count > YukoMyNumberAppProperties.sharedInstance.PassCodeCharactersCount){
      
      return false
    }

    return true
  }
  
  func tapSavePassCodeButton(sender:UIBarButtonItem){
    
    if(self.changePassCodeMode == CHANGEPASSCODEMODE.NEW){
      if(self.PassCodeBefore.text?.characters.count == 0 ||
        self.PassCodeAfter.text?.characters.count == 0){
      
          //必須入力エラー
          let myAlert = UIAlertController(title: "\(self.buttontitle)できませんでした", message: "入力していない項目があります。", preferredStyle: UIAlertControllerStyle.Alert)
          let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
            
          })
          myAlert.addAction(OKAction)
          
          presentViewController(myAlert, animated: true, completion: nil)
          
          return
      }
      if(self.PassCodeBefore.text != PassCodeAfter.text){
        
        //変更後パスワードと再入力の内容アンマッチエラー
        let myAlert = UIAlertController(title: "\(self.buttontitle)", message: "暗証番号が一致していません。\n登録内容を確認してください。", preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
          
        })

        myAlert.addAction(OKAction)
        
        presentViewController(myAlert, animated: true, completion: nil)
        
        return
      }
      
    }else{
      if((self.EmployeeEditData?.PassCode.characters.count != 0 && self.PassCodeBefore.text?.characters.count == 0) ||
        self.PassCodeAfter.text?.characters.count == 0 ||
        self.PassCodeAfterReEnter.text?.characters.count == 0){
      
          //必須入力エラー
          let myAlert = UIAlertController(title: "\(self.buttontitle)できませんでした", message: "入力していない項目があります。", preferredStyle: UIAlertControllerStyle.Alert)
          let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
            
          })
          myAlert.addAction(OKAction)
          
          presentViewController(myAlert, animated: true, completion: nil)
          
          return
      }
      
      if(PassCodeAfter.text != PassCodeAfterReEnter.text){
        //変更後パスワードと再入力の内容アンマッチエラー
        let myAlert = UIAlertController(title: "\(self.buttontitle)できませんでした", message: "変更後の暗証番号が一致していません。\n登録内容を確認してください。", preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
          
        })
        
        myAlert.addAction(OKAction)
        
        presentViewController(myAlert, animated: true, completion: nil)
        
        return
      }
      
      if(self.PassCodeBefore.text == self.PassCodeAfter.text){
        //変更前後が同じエラー
        let myAlert = UIAlertController(title: "\(self.buttontitle)できませんでした", message: "変更前後の暗証番号が同じです。\n登録内容を確認してください。", preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
          
        })
        
        myAlert.addAction(OKAction)
        
        presentViewController(myAlert, animated: true, completion: nil)
        return
      }
    }
    
  
    try! realm.write({ () -> Void in
      
      self.EmployeeEditData!.PassCode = self.PassCodeAfter.text!
      
      let labeltitle = YukoMyNumberAppProperties.sharedInstance.PassCodeLabelName
      
      let myAlert = UIAlertController(title: "\(labeltitle)変更", message: "\(labeltitle)を変更しました", preferredStyle: UIAlertControllerStyle.Alert)
      let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
        handler: { (action:UIAlertAction) -> Void in
      
          self.navigationController?.popViewControllerAnimated(true)
      })
      
      myAlert.addAction(OKAction)
      self.presentViewController(myAlert, animated: true, completion: nil)
    })
    
  }

}


