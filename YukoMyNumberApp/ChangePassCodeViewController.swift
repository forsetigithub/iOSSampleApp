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

class ChangePassCodeViewController:UITableViewController{

  var EmployeeEditData:EmployeeData?
  
  private let realm = try! Realm()
  
  @IBOutlet weak var PassCodeBefore: UITextField!
  @IBOutlet weak var PassCodeAfter: UITextField!
  @IBOutlet weak var PassCodeAfterReEnter: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
   
    self.navigationItem.title = "暗証番号を変更"
    let saveButtonItem = UIBarButtonItem(title: "変更", style: UIBarButtonItemStyle.Done, target: self, action: "tapSavePassCodeButton:")
    self.navigationItem.rightBarButtonItem = saveButtonItem
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewWillAppear(animated: Bool) {
    self.navigationController?.toolbarHidden = true
  }
  
  func tapSavePassCodeButton(sender:UIBarButtonItem){
    
    if((self.EmployeeEditData?.PassCode.characters.count != 0 && self.PassCodeBefore.text?.characters.count == 0) ||
      self.PassCodeAfter.text?.characters.count == 0 ||
      self.PassCodeAfterReEnter.text?.characters.count == 0){
    
        //必須入力エラー
        return
    }
    
    if(PassCodeAfter.text != PassCodeAfterReEnter.text){
      //変更後パスワードと再入力の内容アンマッチエラー
      return
    }
    
    if(self.PassCodeBefore.text == self.PassCodeAfter.text){
      //変更前後が同じエラー
      return
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


