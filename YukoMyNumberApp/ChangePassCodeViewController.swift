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
  case new
  case modify
}

class ChangePassCodeViewController:UITableViewController,UITextFieldDelegate{

  var EmployeeEditData:EmployeeData?
  
  fileprivate let realm = try! Realm()
  
  @IBOutlet weak var PassCodeBefore: UITextField!
  @IBOutlet weak var PassCodeAfter: UITextField!
  @IBOutlet weak var PassCodeAfterReEnter: UITextField!
  
  fileprivate let Properties = YukoMyNumberAppProperties.sharedInstance
  
  fileprivate var InputPassCode:String?
  
  fileprivate var changePassCodeMode:CHANGEPASSCODEMODE?
  fileprivate var buttontitle:String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.PassCodeBefore.delegate = self
    self.PassCodeAfter.delegate = self
    self.PassCodeAfterReEnter.delegate = self
    
    let regstring = Properties.ButtonTitles["Register"]!
    let modstring = Properties.ButtonTitles["Modify"]!
    let titlestring = Properties.NavigationTitles["ChangePassCodeViewController"]!
    
    var title = "\(titlestring)\(regstring)"
    
    buttontitle = regstring
    
    changePassCodeMode = CHANGEPASSCODEMODE.new
    
    if(EmployeeEditData?.PassCode.characters.count != 0){
      title = "\(titlestring)\(modstring)"
      buttontitle = modstring
      
      changePassCodeMode = CHANGEPASSCODEMODE.modify
    }
    
    self.navigationItem.title = title
    let saveButtonItem = UIBarButtonItem(title: buttontitle, style: UIBarButtonItemStyle.done, target: self, action: #selector(ChangePassCodeViewController.tapSavePassCodeButton(_:)))
    self.navigationItem.rightBarButtonItem = saveButtonItem
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.isToolbarHidden = true
    
    if(changePassCodeMode == CHANGEPASSCODEMODE.new){
      self.PassCodeBefore.placeholder = "\(Properties.LabelItems["PassCode"]!)(\(Properties.PassCodeCharactersCount)\(Properties.LabelItems["NumberOfDigits"]!))"
      self.PassCodeAfter.placeholder = "\(Properties.LabelItems["PassCode"]!)(\(Properties.LabelItems["ReEnter"]!))"
      self.PassCodeAfterReEnter.isHidden = true
    }else{
      self.PassCodeBefore.placeholder = "\(Properties.LabelItems["PassCodeBefore"]!)"
      self.PassCodeAfter.placeholder = "\(Properties.LabelItems["PassCodeAfter"]!)"
      self.PassCodeAfterReEnter.placeholder = "\(Properties.LabelItems["PassCodeReAfter"]!)"
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.PassCodeBefore.becomeFirstResponder()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if(changePassCodeMode == CHANGEPASSCODEMODE.new){
      return 2
    }else{
      return 3
    }
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    //暗証番号の桁数しか入力できないようにする

    let str = textField.text! + string
    if(str.characters.count > Properties.PassCodeCharactersCount){
      
      return false
    }

    return true
  }
  
  func tapSavePassCodeButton(_ sender:UIBarButtonItem){
    
    if(self.changePassCodeMode == CHANGEPASSCODEMODE.new){
      if(self.PassCodeBefore.text?.isEmpty == true ||
        self.PassCodeAfter.text?.isEmpty == true){
      
          //必須入力エラー
          let myAlert = UIAlertController(title: "\(self.buttontitle)できませんでした", message: "入力していない項目があります。", preferredStyle: UIAlertControllerStyle.alert)
          let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { (action:UIAlertAction) -> Void in
            
          })
          myAlert.addAction(OKAction)
          
          present(myAlert, animated: true, completion: nil)
          
          return
      }
      if(self.PassCodeBefore.text != PassCodeAfter.text){
        
        //変更後パスワードと再入力の内容アンマッチエラー
        let myAlert = UIAlertController(title: "\(self.buttontitle)", message: "\(self.Properties.LabelItems["PassCode"])が一致していません。\n登録内容を確認してください。", preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { (action:UIAlertAction) -> Void in
          
        })

        myAlert.addAction(OKAction)
        
        present(myAlert, animated: true, completion: nil)
        
        return
      }
      
    }else{
      if((self.EmployeeEditData?.PassCode.isEmpty == false && self.PassCodeBefore.text?.isEmpty == true) ||
        self.PassCodeAfter.text?.isEmpty == true ||
        self.PassCodeAfterReEnter.text?.isEmpty == true){
      
          //必須入力エラー
          let myAlert = UIAlertController(title: "\(self.buttontitle)できませんでした", message: "入力していない項目があります。", preferredStyle: UIAlertControllerStyle.alert)
          let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { (action:UIAlertAction) -> Void in
            
          })
          myAlert.addAction(OKAction)
          
          present(myAlert, animated: true, completion: nil)
          
          return
      }
      
      if(PassCodeAfter.text != PassCodeAfterReEnter.text){
        //変更後パスワードと再入力の内容アンマッチエラー
        let myAlert = UIAlertController(title: "\(self.buttontitle)できませんでした", message: "変更後の暗証番号が一致していません。\n登録内容を確認してください。", preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { (action:UIAlertAction) -> Void in
          
        })
        
        myAlert.addAction(OKAction)
        
        present(myAlert, animated: true, completion: nil)
        
        return
      }
      
      if(self.PassCodeBefore.text == self.PassCodeAfter.text){
        //変更前後が同じエラー
        let myAlert = UIAlertController(title: "\(self.buttontitle)できませんでした", message: "変更前後の暗証番号が同じです。\n登録内容を確認してください。", preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { (action:UIAlertAction) -> Void in
          
        })
        
        myAlert.addAction(OKAction)
        
        present(myAlert, animated: true, completion: nil)
        return
      }
    }
    
  
    try! realm.write({ () -> Void in
      
      self.EmployeeEditData!.PassCode = self.PassCodeAfter.text!
      
      self.resignFirstResponder()
      
      let labeltitle:String = (Properties.LabelItems["PassCode"]! as String)
      
      let myAlert = UIAlertController(title: "\(labeltitle)変更", message: "\(labeltitle)を変更しました", preferredStyle: UIAlertControllerStyle.alert)
      let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
        handler: { (action:UIAlertAction) -> Void in
      
          self.navigationController?.popViewController(animated: true)
      })
      
      myAlert.addAction(OKAction)
      self.present(myAlert, animated: true, completion: nil)
    })
    
  }

}


