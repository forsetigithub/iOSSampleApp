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


class GetMyNumberViewController : UITableViewController,UITextFieldDelegate{
  
  @IBOutlet weak var MyNumberTextField: UITextField!
  @IBOutlet weak var showMyNumberLabel: UILabel!
  @IBOutlet weak var subjectName: UILabel!

  
  private let myActivityIndicatior:UIActivityIndicatorView = UIActivityIndicatorView()
  
  private let realm = try! Realm()
    
  var MyNumberEditData:EmployeeData = EmployeeData()

  // MARK: - Table View
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.MyNumberTextField.delegate = self
    self.title = "マイナンバー登録"
    self.subjectName.text = MyNumberEditData.FamilyName + "　" + MyNumberEditData.FirstName
    
    myActivityIndicatior.frame = CGRectMake(0, 0, 50, 50)
    myActivityIndicatior.center = self.view.center
    myActivityIndicatior.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    
    self.view.addSubview(myActivityIndicatior)
  }
  
  override func viewWillAppear(animated: Bool) {
    self.MyNumberTextField.text = MyNumberEditData.MyNumber
  }
  
  override func viewDidAppear(animated: Bool) {
    self.MyNumberTextField.becomeFirstResponder()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    var ret = true
    
    let str:String = textField.text! + string
    
    if(str.characters.count > YukoMyNumberAppProperties.sharedInstance.MyNumberCharactersCount as Int ){
      
      ret = false
    }
    
    return ret
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    return true
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    

  }
  
  override func viewWillDisappear(animated: Bool) {
  

  }
  
  @IBAction func changeShowMyNumberSwitch(sender: UISwitch) {
    self.MyNumberTextField.resignFirstResponder()
    if(sender.on){
      self.showMyNumberLabel.text = "表示"
      
    }else{
      self.showMyNumberLabel.text = "非表示"
    }
    
    self.MyNumberTextField.secureTextEntry = !(self.MyNumberTextField.secureTextEntry)
  
  }

  @IBAction func tapRegisterButton(sender: UIButton) {
    
    if((self.MyNumberTextField.text?.isValidMyNumber())! == false){
      
      let myAlert:UIAlertController = UIAlertController(title: "マイナンバー入力エラー", message: "マイナンバーが未入力もしくは入力に誤りがあります。", preferredStyle: UIAlertControllerStyle.Alert)
      
      let OKAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
        
      })
      
      myAlert.addAction(OKAction)
      presentViewController(myAlert, animated: true, completion: nil)
      return
    }
    
    self.myActivityIndicatior.startAnimating()
    
    try! realm.write { () -> Void in
      let result = realm.objects(EmployeeData).filter("EmployeeCode = '\(MyNumberEditData.EmployeeCode)'" +
        " and RSCode = '\(MyNumberEditData.RSCode)'")

      if(result.count == 1){
        
        result[0].MyNumber = self.MyNumberTextField.text!
        
        self.myActivityIndicatior.stopAnimating()
        self.navigationController?.popViewControllerAnimated(true)
        
      }else{
        let myAlert:UIAlertController = UIAlertController(title: "エラー", message: "同じ続柄が\(result.count)件登録されているためマイナンバーを登録できません！", preferredStyle: UIAlertControllerStyle.Alert)
        
        let OKAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
          self.myActivityIndicatior.stopAnimating()
          self.MyNumberTextField.resignFirstResponder()
        })
        
        myAlert.addAction(OKAction)
        
        presentViewController(myAlert, animated: true, completion: nil)
      }
    }
  }
}