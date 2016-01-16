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
    
    if(str.characters.count > YukoMyNumberAppProperties.sharedInstance.MyNumberCharactersCount as Int){
      
      myNumberCheckDigit()
      ret = false
    }
    
    return ret
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    return true
  }
  
  func myNumberCheckDigit() -> Bool{
    
    var checkReturn = true
    
    
    
    return checkReturn
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
    
    self.myActivityIndicatior.startAnimating()
    
    try! realm.write { () -> Void in
      let result = realm.objects(EmployeeData).filter("EmployeeCode = '\(MyNumberEditData.EmployeeCode)'" +
        " and RSCode = '\(MyNumberEditData.RSCode)'")

      if(result.count == 1){
        result[0].MyNumber = self.MyNumberTextField.text!
        
        self.myActivityIndicatior.stopAnimating()
        
        self.navigationController?.popViewControllerAnimated(true)
      }
    }
  }
}