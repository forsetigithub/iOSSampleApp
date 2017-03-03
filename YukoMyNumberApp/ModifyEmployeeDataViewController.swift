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
  
  fileprivate let client = SQLClient()
  fileprivate let realm = try! Realm()
  fileprivate let Properties = YukoMyNumberAppProperties.sharedInstance
  
  enum ModifyModeEnum{
    case employee
    case name
  }
  
  var EmployeeEditData:EmployeeData = EmployeeData()
  var ModifyMode:ModifyModeEnum = ModifyModeEnum.employee
  
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
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Properties.ButtonTitles["Modify"], style: UIBarButtonItemStyle.done, target: self, action: #selector(ModifyEmployeeDataViewController.tapModifyButton(_:)))
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    self.EmployeeCodeTextField.text = EmployeeEditData.EmployeeCode
    self.FamilyNameTextField.text = EmployeeEditData.FamilyName
    self.FirstNameTextField.text = EmployeeEditData.FirstName

    if(ModifyMode == ModifyModeEnum.employee){
      changeTextAttribute(FamilyNameTextField)
      changeTextAttribute(FirstNameTextField)

    }else{
      changeTextAttribute(EmployeeCodeTextField)
    }
    
    self.navigationController?.isToolbarHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    


  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
    let str = textField.text! + string
    
    switch textField.tag{
      case 1:
        if(str.characters.count > YukoMyNumberAppProperties.sharedInstance.EmployeeCodeCharactersCount){
          
          return false
        }else if(str.characters.count == YukoMyNumberAppProperties.sharedInstance.EmployeeCodeCharactersCount){

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
  
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    
    return true
  }
  
  func changeTextAttribute(_ textField:UITextField){
    if let cell = textField.superview?.superview as? UITableViewCell{
      cell.isUserInteractionEnabled = false
    }
    
    textField.isEnabled = false
    textField.textColor = UIColor.lightGray
  }
  
  func tapModifyButton(_ sender:UIBarButtonItem){
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
  func modifySQLServerData(_ uploaddata:EmployeeData){
    
    SVProgressHUD.show()
    
    let info = Properties.ServerInfo
    
    client.connect(info["IPAddress"], username: info["UserName"], password: info["Password"],
      database: info["DataBaseName"]) { (success:Bool) -> Void in
     
      print("Connection Successed!")
      
      //変更したEmployeeCodeが使用済みでないかどうかのチェック
      let checksqlstring = "SELECT A0.EmployeeCode as A0_EmployeeCode,AffliationCode,AlreadyUsedFlg,MyNumberRegistedFlg,B0.EmployeeCode as B0_EmployeeCode" +
          " FROM T_EmployeeAffliationRelation as A0 left join T_Employee as B0 on " +
          "A0.EmployeeCode = B0.EmployeeCode where A0.EmployeeCode= '\(self.EmployeeCodeTextField.text!)'"

      self.client.execute(checksqlstring, completion: { (results:[Any]?) -> Void in
        
        if((results?[0] as AnyObject).count == 0){
          
          self.putAlertMessage(self.Properties.AlertMessages["NotRegisteredEmployeeCodeError"])
          
        }else{
          let selectedData = (results?[0] as! NSArray)[0] as AnyObject
            
          if((selectedData["AlreadyUsedFlg"] as! NSString).intValue == 1 &&
            (selectedData["MyNumberRegistedFlg"] as! NSString).intValue == 1){
            
            self.putAlertMessage(self.Properties.AlertMessages["DoubleCheckError"])
            
          }else{
            //SQLサーバデータ更新
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            _ = dateformatter.string(from: Date())
            
            var sqlstring = "update T_Employee Set EmployeeCode = '\(self.EmployeeCodeTextField.text!)', " +
              "FamilyName = '\(self.FamilyNameTextField.text!)',FirstName = '\(self.FirstNameTextField.text!)' " +
              "where EmployeeCode = '\(uploaddata.EmployeeCode)';"
            
            let sqlstring2 = "update T_EmployeeAffliationRelation set AlreadyUsedFlg = 0 where EmployeeCode = '\(self.EmployeeEditData.EmployeeCode)';"
            let sqlstring3 = "update T_EmployeeAffliationRelation set AlreadyUsedFlg = 1 where EmployeeCode = '\(self.EmployeeCodeTextField.text!)';"
            
            sqlstring = sqlstring + sqlstring2 + sqlstring3
            
            print("update = \(sqlstring)")
            
            self.client.execute(sqlstring, completion: { (results:[Any]?) -> Void in
              
              //Realm更新
              try! self.realm.write({ () -> Void in
                self.EmployeeEditData.EmployeeCode = self.EmployeeCodeTextField.text!
                self.EmployeeEditData.FamilyName = self.FamilyNameTextField.text!
                self.EmployeeEditData.FirstName = self.FirstNameTextField.text!
              })
              
              self.client.disconnect()
              SVProgressHUD.dismiss()
              self.navigationController?.popViewController(animated: true)
            })
          }
        }
      })
    }
  }

  func error(_ error: String!, code: Int32, severity: Int32) {
    print("error=\(error) code = \(code) serverity = \(severity)")
  }
  
  func putAlertMessage(_ alertProp:AnyObject!){
    let alertProp = alertProp as! [String:String]
    
    SVProgressHUD.dismiss()
    
    let myAlert = UIAlertController(title: alertProp["Title"]!, message: alertProp["Message"]!, preferredStyle: UIAlertControllerStyle.alert)
    let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { (action:UIAlertAction) -> Void in
      
    })
    
    myAlert.addAction(OKAction)
    self.present(myAlert, animated: true, completion: nil)
  }
}
