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
import SQLClient

class RegisterEmployeeViewController : UITableViewController,UITextFieldDelegate,SQLClientDelegate {
  
  private let realm = try! Realm()
  private let client:SQLClient = SQLClient()
  
  private let Properties = YukoMyNumberAppProperties.sharedInstance
  
  // MARK: - Table View
  @IBOutlet weak var EmployeeCode: UITextField!
  @IBOutlet weak var EmployeeFamilyName: UITextField!
  @IBOutlet weak var EmployeeFirstName: UITextField!
  @IBOutlet weak var EmployeeJoinedDateLabel: UILabel!
  
  @IBOutlet weak var JoinedDatePicker: UIDatePicker!

  var JoinedDate:NSDate?
  let formatter = DateFormatter()
  
  private var InitialJoinedDateLabel:String!
  private var JoinedDateTappedFlag:Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    client.delegate = self
    
    EmployeeCode.delegate = self
    EmployeeFamilyName.delegate = self
    EmployeeFirstName.delegate = self

    
    self.navigationItem.title = Properties.NavigationTitles["RegisterEmployeeViewController"]

    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Properties.ButtonTitles["Register"], style: UIBarButtonItem.Style.done, target: self, action:#selector(self.tapRegisterButton(sender:)))
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: Properties.ButtonTitles["Cancel"], style: UIBarButtonItem.Style.plain, target: self, action:#selector(self.tapCancelButton(sender:)))
    
    self.EmployeeCode.placeholder = Properties.LabelItems["EmployeeCode"]
    self.EmployeeFamilyName.placeholder = Properties.LabelItems["FamilyName"]
    self.EmployeeFirstName.placeholder = Properties.LabelItems["FirstName"]
    
    formatter.dateFormat = Properties.DateFormatStringSeparetedJapanese
    self.InitialJoinedDateLabel = self.EmployeeJoinedDateLabel.text
    self.JoinedDatePicker.locale = NSLocale(localeIdentifier: Properties.LocaleIdentifier) as Locale
    
    let tapgesture = UITapGestureRecognizer(target: self, action: #selector(self.tapEmployeeJoinedDateLabel(sender:)))
    self.EmployeeJoinedDateLabel.isUserInteractionEnabled = true
    self.EmployeeJoinedDateLabel.addGestureRecognizer(tapgesture)
    self.EmployeeJoinedDateLabel.text = Properties.JoinedDateLabelTapComment
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    self.navigationController?.isToolbarHidden = true
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if(self.EmployeeCode.text?.isEmpty == true){
      self.EmployeeCode.becomeFirstResponder()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 3
  }
  

   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = Properties.TableViewCellDefaultHeight
        
        if(indexPath.section == 2 && indexPath.row == 1){
            if(self.JoinedDateTappedFlag == true){
                height = 150
                self.EmployeeJoinedDateLabel.text = formatter.string(from: self.JoinedDatePicker.date)
            }else{
                height = 0
            }
        }
        
        return height
    }

    
  func textFieldDidEndEditing(_ textField: UITextField) {

  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
    let str = textField.text! + string
    
    switch textField.tag {
      //社員番号
      case 1:
        if(str.characters.count > Properties.EmployeeCodeCharactersCount){
          return false
        }
        break
        
      //姓・名
      case 2,3:
        if(str.characters.count > Properties.EmployeeNameCharactersCount){
          return false
        }
        break
      
      default:
        break
    }
    
    return true
  }
  
  @objc func tapEmployeeJoinedDateLabel(sender: UITapGestureRecognizer) {
    self.JoinedDateTappedFlag = !(self.JoinedDateTappedFlag)
    
    if(self.JoinedDateTappedFlag == true){
      self.EmployeeJoinedDateLabel.textColor = UIColor.blue
      
    }else{
      self.EmployeeJoinedDateLabel.textColor = UIColor.black
    }
    
    self.JoinedDate = self.JoinedDatePicker.date as NSDate?
    self.tableView.reloadData()

  }
  
  @IBAction func changeDatePickerValue(sender: UIDatePicker) {
    
    self.JoinedDate = sender.date as NSDate?
    self.EmployeeJoinedDateLabel.text = self.formatter.string(from: self.JoinedDate! as Date)
    
  }
  
  
  @objc internal func tapRegisterButton(sender: UIBarButtonItem) {

    //必須入力チェック
    if(self.EmployeeCode.text?.replacingOccurrences(of: " ", with: "").isEmpty == true ||
      self.EmployeeFamilyName.text?.replacingOccurrences(of: " ", with: "").isEmpty == true ||
      self.EmployeeFirstName.text?.replacingOccurrences(of: " ", with: "").isEmpty == true  ||
      self.EmployeeJoinedDateLabel.text == Properties.JoinedDateLabelTapComment ){
        
        let requiredvalid:[String:String] = Properties.AlertMessages["RequiredItemValidError"] as! [String:String]
        
        let myAlert = UIAlertController(title: requiredvalid["Title"], message: requiredvalid["Message"], preferredStyle: UIAlertController.Style.alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: { (action:UIAlertAction) -> Void in
          
        })
        
        myAlert.addAction(OKAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
        self.resignFirstResponder()
        
        return
    }

    registerEmployeeData()

  }

  @IBAction func tapCancelButton(sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
  func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

  }
  
  func registerEmployeeData(){
    
    //データ登録
    let NewEmployeeData = EmployeeData()
    NewEmployeeData.EmployeeCode = self.EmployeeCode.text!
    NewEmployeeData.FamilyName = self.EmployeeFamilyName.text!
    NewEmployeeData.FirstName = self.EmployeeFirstName.text!
    NewEmployeeData.FamilySeqNo = 0
    NewEmployeeData.RSCode = "00"
    
    if let joineddate = self.JoinedDate{
      NewEmployeeData.JoinedDate = joineddate as Date
    }
    
    NewEmployeeData.CreateDateTime = NSDate() as Date
  
    if(realm.objects(EmployeeData.self).filter("EmployeeCode = '\(NewEmployeeData.EmployeeCode)'").count != 0){
      
      let doubleerror:[String:String] = Properties.AlertMessages["DoubleCheckError"] as! [String:String]
      
      let myAlert = UIAlertController(title: doubleerror["Title"]!, message: "入力した\(Properties.LabelItems["EmployeeCode"]!)は\n\(doubleerror["Message"]!)", preferredStyle: UIAlertController.Style.alert)
      let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: nil)
      
      myAlert.addAction(OKAction)
      present(myAlert, animated: true, completion: nil)
      return
    }
    
    uploadData(uploaddata: NewEmployeeData)

  }
  
  /*
  * データをSQLServerへ登録する
  */
  func uploadData(uploaddata:EmployeeData){
    
    SVProgressHUD.show()
    
    let info = Properties.ServerInfo
    
    client.connect(info["IPAddress"], username: info["UserName"], password: info["Password"],
      database: info["DataBaseName"]) { (success:Bool) -> Void in
        
        if(success){
          
          print("Connection Successed!")
          
          let dateformatter = DateFormatter()
          dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
          
          let timestamp = dateformatter.string(from: NSDate() as Date)
          
          var checksqlstring = "SELECT A0.EmployeeCode as A0_EmployeeCode,AffliationCode,AlreadyUsedFlg,MyNumberRegistedFlg,B0.EmployeeCode as B0_EmployeeCode" +
                              " FROM T_EmployeeAffliationRelation as A0 left join T_Employee as B0 on " +
                              "A0.EmployeeCode = B0.EmployeeCode where A0.EmployeeCode= '\(uploaddata.EmployeeCode)'"
          
          self.client.execute(checksqlstring, completion: { (results:[Any]?) -> Void in

            if((results?[0] as AnyObject).count == 0){
              
              self.putAlertMessage(alertProp: self.Properties.AlertMessages["NotRegisteredEmployeeCodeError"])

            }else{
              let selectedData = (results?[0] as! NSArray?)?[0] as AnyObject?
                
              if((selectedData!["AlreadyUsedFlg"] as! NSString).intValue == 1 &&
                (selectedData!["MyNumberRegistedFlg"] as! NSString).intValue == 0){
                
                self.putAlertMessage(alertProp: self.Properties.AlertMessages["DoubleCheckError"])

              }else{
                var sqlstring = "insert into T_Employee(" +
                  "SeqNo,EmployeeCode,RecKindNo,RelationCode,FamilyName,FirstName,JoinedDate,MyNumber,TimeStamp" +
                  ") values " +
                  "(NEWID()," +
                  "'\(uploaddata.EmployeeCode)'," +
                  "1," +
                  "'\(uploaddata.RSCode)'," +
                  "'\(uploaddata.FamilyName)'," +
                  "'\(uploaddata.FirstName)'," +
                  "'\(dateformatter.string(from: uploaddata.JoinedDate))'," +
                  "'\(uploaddata.MyNumber)'," +
                  "'\(timestamp)'" +
                ");"
                
                let sqlstring2 = "update T_EmployeeAffliationRelation set AlreadyUsedFlg = 1 where EmployeeCode = '\(uploaddata.EmployeeCode)'"
                
                sqlstring = sqlstring + sqlstring2
                
                print(sqlstring)
                
                self.client.execute(sqlstring, completion: { (results:[Any]?) -> Void in
                  
                  checksqlstring = "select * from T_Employee where EmployeeCode = '\(uploaddata.EmployeeCode)' and TimeStamp = '\(timestamp)'"
                  
                  print(checksqlstring)
                  
                  self.client.execute(checksqlstring, completion: { (results:[Any]?) -> Void in
                    
                    if((results?[0] as AnyObject).count != 0){
                      //データ登録
                      try! self.realm.write({ () -> Void in
                        let selectedData = (results?[0] as! NSArray)[0] as AnyObject
                        
                        uploaddata.SQLServerSeqNo = selectedData["SeqNo"] as! String
                        self.realm.add(uploaddata)
                      })
                      
                      self.dismiss(animated: true, completion: nil)
                      
                    }else{
                      
                      let uploaderror:[String:String] = self.Properties.AlertMessages["UploadNotCompleteError"] as! [String:String]
                      let messageAlert = UIAlertController(title: uploaderror["Title"], message:"入力した\(self.Properties.LabelItems["EmployeeCode"])は\(uploaderror["Message"])" , preferredStyle: UIAlertController.Style.alert)
                      let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: { (action:UIAlertAction) -> Void in
                        
                      })
                      
                      messageAlert.addAction(OKAction)
                      self.present(messageAlert, animated: true, completion: nil)
                    }
                    
                    self.client.disconnect()
                    print("Disconnected")
                    SVProgressHUD.dismiss()
                  })
                })
              
              }
            }
          })
    
        }else{
          SVProgressHUD.dismiss()
          print("Error Connect")
          return
        }
    }
  }
  
  func error(_ error: String!, code: Int32, severity: Int32) {
    print("error = \(error),code = \(code),severity = \(severity)")
  }
  
  func putAlertMessage(alertProp:AnyObject!){
    let alertProp = alertProp as! [String:String]
    
    SVProgressHUD.dismiss()
    
    let myAlert = UIAlertController(title: alertProp["Title"]!, message: alertProp["Message"]!, preferredStyle: UIAlertController.Style.alert)
    let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: { (action:UIAlertAction) -> Void in
      
    })
    
    myAlert.addAction(OKAction)
    self.present(myAlert, animated: true, completion: nil)
  }
}
