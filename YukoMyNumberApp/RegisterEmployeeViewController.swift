//
//  RegisterAddNewViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/06.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD

class RegisterEmployeeViewController : UITableViewController,UITextFieldDelegate {
  
  let realm = try! Realm()
  let client:SQLClient = SQLClient()
  
  // MARK: - Table View  
  @IBOutlet weak var EmployeeCode: UITextField!
  @IBOutlet weak var EmployeeFamilyName: UITextField!
  @IBOutlet weak var EmployeeFirstName: UITextField!
  @IBOutlet weak var EmployeeJoinedDateLabel: UILabel!
  @IBOutlet weak var PassCodeTextField: UITextField!
  @IBOutlet weak var RePassCodeTextField: UITextField!
  
  
  var JoinedDate:NSDate?
  let formatter = NSDateFormatter()
  
  private var InputPassCode:String? //暗証番号(初回)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    EmployeeCode.delegate = self
    EmployeeFamilyName.delegate = self
    EmployeeFirstName.delegate = self
    PassCodeTextField.delegate = self
    RePassCodeTextField.delegate = self
    
    self.navigationItem.title = "新規登録"
    formatter.dateFormat = "yyyy年 MM月 dd日"
  
  }
  
  override func viewWillAppear(animated: Bool) {
    
    self.navigationController?.toolbarHidden = true
    
    if(JoinedDate != nil){
      EmployeeJoinedDateLabel.text = formatter.stringFromDate(JoinedDate!)
      self.resignFirstResponder()
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    if(self.EmployeeCode.text?.characters.count == 0){
      self.EmployeeCode.becomeFirstResponder()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
  
    if((textField.tag == 1 || textField.tag == 2) &&
      textField.text?.characters.count != 0 && textField.text?.characters.count != YukoMyNumberAppProperties.sharedInstance.PassCodeCharactersCount){
    
        let myAlert = UIAlertController(title: "", message: "暗証番号は\((YukoMyNumberAppProperties.sharedInstance.PassCodeCharactersCount)!)桁で入力してください。", preferredStyle: UIAlertControllerStyle.Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
          textField.text?.removeAll()
          textField.becomeFirstResponder()
          
        })
        
        myAlert.addAction(OKAction)
        presentViewController(myAlert, animated: true, completion: nil)
    }
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
    //暗証番号の桁数しか入力できないようにする
    if(textField.tag == 1 || textField.tag == 2){
      let str = textField.text! + string
      if(str.characters.count > YukoMyNumberAppProperties.sharedInstance.PassCodeCharactersCount){
        
        return false
        
      }else if(textField.tag == 2 && str.characters.count ==
        YukoMyNumberAppProperties.sharedInstance.PassCodeCharactersCount && str != self.InputPassCode){
          
          let myAlert = UIAlertController(title: "エラー", message: "入力した暗証番号が一致していません！", preferredStyle: UIAlertControllerStyle.Alert)
          let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
            textField.text?.removeAll()
          })
          
          myAlert.addAction(OKAction)
          
          presentViewController(myAlert, animated: true, completion: nil)
        
      }else{
        if(textField.tag == 1){
          self.InputPassCode = str
        }
      }
    }
    
    return true
  }


  
  @IBAction func tapRegisterButton(sender: UIBarButtonItem) {
    
    //入力チェック
#if DEBUG
#else
    //必須入力チェック
    if(self.EmployeeCode.text?.characters.count == 0 ||
      self.EmployeeFamilyName.text?.characters.count == 0 ||
      self.EmployeeFirstName.text?.characters.count == 0 ||
      self.JoinedDate == nil ||
      self.PassCodeTextField.text?.characters.count == 0){
        
        let myAlert = UIAlertController(title: "必須項目入力エラー", message: "入力されていない項目があります。", preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
          
         
        })
        
        myAlert.addAction(OKAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
        
        self.resignFirstResponder()
        
        return
    }
  
#endif
    
    //データ登録
    try! realm.write({ () -> Void in
      let NewEmployeeData = EmployeeData()
      NewEmployeeData.EmployeeCode = self.EmployeeCode.text!
      NewEmployeeData.FamilyName = self.EmployeeFamilyName.text!
      NewEmployeeData.FirstName = self.EmployeeFirstName.text!
      NewEmployeeData.FamilySeqNo = 0
      NewEmployeeData.RSCode = "00"
      if let joineddate = self.JoinedDate{
        NewEmployeeData.JoinedDate = joineddate
      }else{
      
      }
      
      NewEmployeeData.PassCode = self.PassCodeTextField.text!
      NewEmployeeData.CreateDateTime = NSDate()
      self.realm.add(NewEmployeeData)
      
#if DEBUG
#else
      uploadData(NewEmployeeData)
#endif
      

    })
    
  }

  @IBAction func tapCancelButton(sender: UIBarButtonItem) {
     self.performSegueWithIdentifier("showRegisterList", sender: self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if(segue.identifier == "showSelectDate"){
      let dest = segue.destinationViewController as? DatePickerViewController
      dest!.sourceViewController = self
      
    }
  }
  
  /*
  * データをSQLServerへ登録する
  */
  func uploadData(uploaddata:EmployeeData){
    
    SVProgressHUD.show()
    
    let info = YukoMyNumberAppProperties.sharedInstance.ServerInfo
    
    client.connect(info["IPAddress"], username: info["UserName"], password: info["Password"],
      database: info["DataBaseName"]) { (success:Bool) -> Void in
        
        if(success){
          
          print("Connection Successed!")
          
          let list = self.realm.objects(EmployeeData).filter("EmployeeCode = '\(uploaddata.EmployeeCode)'").sorted("FamilySeqNo")
          
          var sqlstringlist:String = ""
          
          let dateformatter = NSDateFormatter()
          dateformatter.dateFormat = "yyyy-MM-dd"
          
          for data in list {
            
            let sqlstring = "insert into T_Employee(" +
              "SeqNo,EmployeeCode,RelationCode,FamilyName,FirstName,JoinedDate,MyNumber,TimeStamp" +
              ") values " +
              "(NEWID()," +
              "'\(data.EmployeeCode)'," +
              "'\(data.RSCode)'," +
              "'\(data.FamilyName)'," +
              "'\(data.FirstName)'," +
              "'\(dateformatter.stringFromDate(data.JoinedDate))'," +
              "'\(data.MyNumber)'," +
              "SYSDATETIME()" +
              ")"
            
            sqlstringlist = sqlstringlist + sqlstring
          }
          
          print(sqlstringlist)
          
          self.client.execute(sqlstringlist, completion: { (results:[AnyObject]!) -> Void in
            self.client.disconnect()
            print("Disconnected")
            
            SVProgressHUD.dismiss()
            
            self.performSegueWithIdentifier("showRegisterList", sender: self)

          })
          
        }else{
          SVProgressHUD.dismiss()
          print("Error Connect")
          return
        }
    }
  }
}