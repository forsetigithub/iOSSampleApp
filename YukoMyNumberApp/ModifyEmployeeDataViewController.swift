//
//  ModifyEmployeeData.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/12.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import SVProgressHUD

class ModifyEmployeeDataViewController: UITableViewController,UITextFieldDelegate,SQLClientDelegate{
  
  private let client = SQLClient()
  private let realm = try! Realm()
  private let Properties = YukoMyNumberAppProperties.sharedInstance
  
  enum ModifyModeEnum{
    case Employee
    case Name
  }
  
  var EmployeeEditData:EmployeeData = EmployeeData()
  var ModifyMode:ModifyModeEnum = ModifyModeEnum.Employee
  
  @IBOutlet weak var EmployeeCodeTextField: UITextField!
  @IBOutlet weak var FamilyNameTextField: UITextField!
  @IBOutlet weak var FirstNameTextField: UITextField!
  
  // MARK: - Table View
  override func viewDidLoad() {
    super.viewDidLoad()
    client.delegate = self
    
    // Do any additional setup after loading the view, typically from a nib.
    EmployeeCodeTextField.delegate = self
    FamilyNameTextField.delegate = self
    FirstNameTextField.delegate = self
    
    EmployeeCodeTextField.placeholder = Properties.LabelItems["EmployeeCode"]
    FamilyNameTextField.placeholder = Properties.LabelItems["FamilyName"]
    FirstNameTextField.placeholder = Properties.LabelItems["FirstName"]
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Properties.ButtonTitles["Modify"], style: UIBarButtonItemStyle.Done, target: self, action: "tapModifyButton:")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewWillAppear(animated: Bool) {
    
    self.EmployeeCodeTextField.text = EmployeeEditData.EmployeeCode
    self.FamilyNameTextField.text = EmployeeEditData.FamilyName
    self.FirstNameTextField.text = EmployeeEditData.FirstName

    if(ModifyMode == ModifyModeEnum.Employee){
      changeTextAttribute(FamilyNameTextField)
      changeTextAttribute(FirstNameTextField)

    }else{
      changeTextAttribute(EmployeeCodeTextField)
    }
    
    self.navigationController?.toolbarHidden = true
  }
  
  override func viewWillDisappear(animated: Bool) {
    


  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
    let str = textField.text! + string
    
    switch textField.tag{
      case 1:
        if(str.characters.count > YukoMyNumberAppProperties.sharedInstance.EmployeeCodeCharactersCount){
          
          return false
        }else if(str.characters.count == YukoMyNumberAppProperties.sharedInstance.EmployeeCodeCharactersCount){
          if(realm.objects(EmployeeData).filter("EmployeeCode = '\(str)' and EmployeeCode !='\(self.EmployeeCodeTextField.text!)'").count != 0){
            
            let doubleerror:[String:String] = Properties.AlertMessages["DoubleCheckError"] as! [String:String]
            
            let myAlert = UIAlertController(title: doubleerror["Title"]!, message: "「\(str)」は\(doubleerror["Message"]!)", preferredStyle: UIAlertControllerStyle.Alert)
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            myAlert.addAction(OKAction)
            self.presentViewController(myAlert, animated: true, completion: nil)
          }
        }

        break
      case 2,3:
        if(str.characters.count > YukoMyNumberAppProperties.sharedInstance.EmployeeNameCharactersCount){
          return false
        }
        break
      default:
        break
    }
    
    return true
  }
  
  func textFieldShouldEndEditing(textField: UITextField) -> Bool {
    
    return true
  }
  
  func changeTextAttribute(textField:UITextField){
    if let cell = textField.superview?.superview as? UITableViewCell{
      cell.userInteractionEnabled = false
    }
    
    textField.enabled = false
    textField.textColor = UIColor.lightGrayColor()
  }
  
  func tapModifyButton(sender:UIBarButtonItem){
    if(self.EmployeeCodeTextField.text?.isEmpty == false &&
      self.FamilyNameTextField.text?.isEmpty == false &&
      self.FirstNameTextField.text?.isEmpty == false &&
      (self.EmployeeCodeTextField.text != EmployeeEditData.EmployeeCode ||
        self.FamilyNameTextField.text != EmployeeEditData.FamilyName ||
        self.FirstNameTextField.text != EmployeeEditData.FirstName)){
          
          modifySQLServerData(EmployeeEditData)
          
    }
  }
  
  /* 
  * SQLサーバのデータチェックおよび更新
  */
  func modifySQLServerData(uploaddata:EmployeeData){
    
    SVProgressHUD.show()
    
    let info = Properties.ServerInfo
    
    
    client.connect(info["IPAddress"], username: info["UserName"], password: info["Password"],
      database: info["DataBaseName"]) { (success:Bool) -> Void in
     
      print("Connection Successed!")
      
      //変更したEmployeeCodeが使用済みでないかどうかのチェック
      var checksqlstring = "select * from T_Employee where EmployeeCode = '\(self.EmployeeCodeTextField.text!)'"
      
      print(checksqlstring)
      
      self.client.execute(checksqlstring, completion: { (results:[AnyObject]!) -> Void in
        if(results[0].count == 0){
          //SQLサーバデータ更新
          let dateformatter = NSDateFormatter()
          dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
          
          let timestamp = dateformatter.stringFromDate(NSDate())
          
          let sqlstring = "update T_Employee Set EmployeeCode = '\(self.EmployeeCodeTextField.text!)', " +
            "FamilyName = '\(self.FamilyNameTextField.text!)',FirstName = '\(self.FirstNameTextField.text!)' " +
            "where EmployeeCode = '\(uploaddata.EmployeeCode)' and SeqNo ='\(self.EmployeeEditData.SQLServerSeqNo)'"

          print("update = \(sqlstring)")
          
          self.client.execute(sqlstring, completion: { (results:[AnyObject]!) -> Void in
            
            //Realm更新
            try! self.realm.write({ () -> Void in
              self.EmployeeEditData.EmployeeCode = self.EmployeeCodeTextField.text!
              self.EmployeeEditData.FamilyName = self.FamilyNameTextField.text!
              self.EmployeeEditData.FirstName = self.FirstNameTextField.text!
            })
            
            self.client.disconnect()
            SVProgressHUD.dismiss()
            self.navigationController?.popViewControllerAnimated(true)
          })
        }else{
          self.client.disconnect()
          SVProgressHUD.dismiss()
        }
      })
    }
  }
 /*
          print("Connection Successed!")
          
          //変更したEmployeeCodeが使用済みでないかどうかのチェック
            var checksqlstring = "select * from T_Employee where EmployeeCode = '\(self.EmployeeCodeTextField.text!)'"
            
            print(checksqlstring)
            
            self.client.execute(checksqlstring, completion: { (results:[AnyObject]!) -> Void in
              
              if(results[0].count == 0){
                //SQLサーバデータ更新
                let dateformatter = NSDateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let timestamp = dateformatter.stringFromDate(NSDate())
                
                //let sqlstring = "update T_Employee Set EmployeeCode = '\(self.EmployeeCodeTextField.text!)', " +
                //  "FamilyName = '\(self.FamilyNameTextField.text!)',FirstName = '\(self.FirstNameTextField.text!)' where EmployeeCode = '\(uploaddata.EmployeeCode)'"
                
                let sqlstring  = "insert into T_Employee(SeqNo,EmployeeCode,FamilyName,FirstName) values(NEWID(),'\(self.EmployeeCodeTextField.text!)','\(self.FamilyNameTextField.text!)','\(self.FirstNameTextField.text!)')"
                
print("update = \(sqlstring)")
                
                self.client.execute(sqlstring, completion: { (results1:[AnyObject]!) -> Void in
                  
                  checksqlstring = "select * from T_Employee where EmployeeCode = '\(self.EmployeeCodeTextField.text!)' and FamilyName = '\(self.FamilyNameTextField.text!)' and " +
                  "FirstName = '\(self.FirstNameTextField.text!)'"
                  
print("checksqlstring = \(checksqlstring)")
                  
                  self.client.execute(checksqlstring,completion:{(results2:[AnyObject]!) -> Void in
                    if(results2[0].count != 0){
                      
                      //Realm更新
                      try! self.realm.write({ () -> Void in
                        self.EmployeeEditData.EmployeeCode = self.EmployeeCodeTextField.text!
                        self.EmployeeEditData.FamilyName = self.FamilyNameTextField.text!
                        self.EmployeeEditData.FirstName = self.FirstNameTextField.text!
                      })
                      
                      SVProgressHUD.dismiss()
                    }
                  })
                })
              }else{
                
                let uploaderror:[String:String] = self.Properties.AlertMessages["UploadNotCompleteError"] as! [String:String]
                let messageAlert = UIAlertController(title: uploaderror["Title"], message: uploaderror["Message"], preferredStyle: UIAlertControllerStyle.Alert)
                
                let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: { (action:UIAlertAction) -> Void in
                  
                })
                
                messageAlert.addAction(OKAction)
                self.presentViewController(messageAlert, animated: true, completion: nil)
              }
              
              self.client.disconnect()
              print("Disconnected")
              
              SVProgressHUD.dismiss()
            })

        }
    }
  }
 */
  func error(error: String!, code: Int32, severity: Int32) {
    print("error=\(error) code = \(code) serverity = \(severity)")
  }
}
