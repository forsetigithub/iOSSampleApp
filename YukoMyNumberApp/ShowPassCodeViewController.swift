//
//  ShowPassCodeViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/15.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ShowPassCodeViewController:UIViewController{
  
  // MARK: - Table View
  override func viewDidLoad() {
    
    super.viewDidLoad()

    // Do any additional setup after loading the view, typically from a nib.
    
    let myAlert:UIAlertController = UIAlertController(title: "暗証番号入力", message: "暗証番号(4桁)を入力してください", preferredStyle: UIAlertControllerStyle.Alert)
    
    let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
      
      self.performSegueWithIdentifier("showRegisterEdit", sender: self)
    })
    
    let CancelAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
      
      self.navigationController?.popViewControllerAnimated(true)
      
    })
    
    myAlert.addTextFieldWithConfigurationHandler({ (textField:UITextField) -> Void in
      
      textField.secureTextEntry = true
      let myNotificationCenter = NSNotificationCenter.defaultCenter()
      
      myNotificationCenter.addObserver(self, selector: "changeTextField:", name: UITextFieldTextDidChangeNotification, object: nil)
    })
    
    myAlert.addAction(OKAction)
    myAlert.addAction(CancelAction)
    
    self.presentViewController(myAlert, animated: true, completion: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  /*
  textFieldに変更が会った時に通知されるメソッド.
  */
  internal func changeTextField (sender: NSNotification) {
    let textField = sender.object as! UITextField
    
    // 入力された文字を表示.
    print(textField.text)
  }

}