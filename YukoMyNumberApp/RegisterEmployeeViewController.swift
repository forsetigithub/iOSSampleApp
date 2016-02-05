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
  let formatter = NSDateFormatter()
  
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
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Properties.ButtonTitles["Register"], style: UIBarButtonItemStyle.Done, target: self, action: "tapRegisterButton:")
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: Properties.ButtonTitles["Cancel"], style: UIBarButtonItemStyle.Plain, target: self, action: "tapCancelButton:")
    
    
    self.EmployeeCode.placeholder = Properties.LabelItems["EmployeeCode"]
    self.EmployeeFamilyName.placeholder = Properties.LabelItems["FamilyName"]
    self.EmployeeFirstName.placeholder = Properties.LabelItems["FirstName"]
    
    formatter.dateFormat = Properties.DateFormatStringSeparetedJapanese
    self.InitialJoinedDateLabel = self.EmployeeJoinedDateLabel.text
    self.JoinedDatePicker.locale = NSLocale(localeIdentifier: Properties.LocaleIdentifier)
    
    let tapgesture = UITapGestureRecognizer(target: self, action: "EmployeeJoinedDateLabel:")
    self.EmployeeJoinedDateLabel.addGestureRecognizer(tapgesture)
    self.EmployeeJoinedDateLabel.text = Properties.JoinedDateLabelTapComment
    
  }
  
  override func viewWillAppear(animated: Bool) {
    
    self.navigationController?.toolbarHidden = true
  }
  
  override func viewDidAppear(animated: Bool) {
    if(self.EmployeeCode.text?.isEmpty == true){
      self.EmployeeCode.becomeFirstResponder()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 3
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    var height:CGFloat = Properties.TableViewCellDefaultHeight
    
    if(indexPath.section == 2 && indexPath.row == 1){
      if(self.JoinedDateTappedFlag == true){
        height = 150
        self.EmployeeJoinedDateLabel.text = formatter.stringFromDate(self.JoinedDatePicker.date)
      }else{
        height = 0
      }
    }
    
    return height
  }

  func textFieldDidEndEditing(textField: UITextField) {

  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
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
  
  func EmployeeJoinedDateLabel(sender: UILabel) {
    self.JoinedDateTappedFlag = !(self.JoinedDateTappedFlag)
    
    if(self.JoinedDateTappedFlag == true){
      self.EmployeeJoinedDateLabel.textColor = UIColor.blueColor()
      
    }else{
      self.EmployeeJoinedDateLabel.textColor = UIColor.blackColor()
    }
    
    self.JoinedDate = self.JoinedDatePicker.date
    self.tableView.reloadData()

  }
  
  @IBAction func changeDatePickerValue(sender: UIDatePicker) {
    
    self.JoinedDate = sender.date
    self.EmployeeJoinedDateLabel.text = self.formatter.stringFromDate(self.JoinedDate!)
    
  }
  
  
  @IBAction func tapRegisterButton(sender: UIBarButtonItem) {

    //必須入力チェック
    if(self.EmployeeCode.text?.stringByReplacingOccurrencesOfString(" ", withString: "").isEmpty == true ||
      self.EmployeeFamilyName.text?.stringByReplacingOccurrencesOfString(" ", withString: "").isEmpty == true ||
      self.EmployeeFirstName.text?.stringByReplacingOccurrencesOfString(" ", withString: "").isEmpty == true  ||
      self.EmployeeJoinedDateLabel.text == self.InitialJoinedDateLabel ){
        
        let requiredvalid:[String:String] = Properties.AlertMessages["RequiredItemValidError"] as! [String:String]
        
        let myAlert = UIAlertController(title: requiredvalid["Title"], message: requiredvalid["Message"], preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: { (action:UIAlertAction) -> Void in
          
        })
        
        myAlert.addAction(OKAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
        
        self.resignFirstResponder()
        
        return
    }

    registerEmployeeData()

  }

  @IBAction func tapCancelButton(sender: UIBarButtonItem) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

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
      NewEmployeeData.JoinedDate = joineddate
    }
    
    NewEmployeeData.CreateDateTime = NSDate()
  
    if(realm.objects(EmployeeData).filter("EmployeeCode = '\(NewEmployeeData.EmployeeCode)'").count != 0){
      
      let doubleerror:[String:String] = Properties.AlertMessages["DoubleCheckError"] as! [String:String]
      
      let myAlert = UIAlertController(title: doubleerror["Title"]!, message: "入力した\(Properties.LabelItems["EmployeeCode"]!)は\n\(doubleerror["Message"]!)", preferredStyle: UIAlertControllerStyle.Alert)
      let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil)
      
      myAlert.addAction(OKAction)
      presentViewController(myAlert, animated: true, completion: nil)
      return
    }
    
    uploadData(NewEmployeeData)

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
          
          let dateformatter = NSDateFormatter()
          dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
          
          let timestamp = dateformatter.stringFromDate(NSDate())
          
          var checksqlstring = "SELECT A0.EmployeeCode as A0_EmployeeCode,AffliationCode,AlreadyUsedFlg,B0.EmployeeCode as B0_EmployeeCode" +
                              " FROM T_EmployeeAffliationRelation as A0 left join T_Employee as B0 on " +
                              "A0.EmployeeCode = B0.EmployeeCode where A0.EmployeeCode= '\(uploaddata.EmployeeCode)'"
          
          self.client.execute(checksqlstring, completion: { (results:[AnyObject]!) -> Void in
            
            if(results[0].count == 0){
              
              self.putAlertMessage(self.Properties.AlertMessages["NotRegisteredEmployeeCodeError"])

            }else{
              if((results[0][0]["AlreadyUsedFlg"] as! NSString).intValue == 1){
                
                self.putAlertMessage(self.Properties.AlertMessages["DoubleCheckError"])

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
                  "'\(dateformatter.stringFromDate(uploaddata.JoinedDate))'," +
                  "'\(uploaddata.MyNumber)'," +
                  "'\(timestamp)'" +
                ");"
                
                let sqlstring2 = "update T_EmployeeAffliationRelation set AlreadyUsedFlg = 1 where EmployeeCode = '\(uploaddata.EmployeeCode)'"
                
                sqlstring = sqlstring + sqlstring2
                
                print(sqlstring)
                
                self.client.execute(sqlstring, completion: { (results:[AnyObject]!) -> Void in
                  
                  checksqlstring = "select * from T_Employee where EmployeeCode = '\(uploaddata.EmployeeCode)' and TimeStamp = '\(timestamp)'"
                  
                  print(checksqlstring)
                  
                  self.client.execute(checksqlstring, completion: { (results:[AnyObject]!) -> Void in
                    
                    if(results[0].count != 0){
                      //データ登録
                      try! self.realm.write({ () -> Void in
                        uploaddata.SQLServerSeqNo = results[0][0]["SeqNo"] as! String
                        self.realm.add(uploaddata)
                      })
                      
                      self.dismissViewControllerAnimated(true, completion: nil)
                      
                    }else{
                      
                      let uploaderror:[String:String] = self.Properties.AlertMessages["UploadNotCompleteError"] as! [String:String]
                      let messageAlert = UIAlertController(title: uploaderror["Title"], message:"入力した\(self.Properties.LabelItems["EmployeeCode"])は\(uploaderror["Message"])" , preferredStyle: UIAlertControllerStyle.Alert)
                      let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: { (action:UIAlertAction) -> Void in
                        
                      })
                      
                      messageAlert.addAction(OKAction)
                      self.presentViewController(messageAlert, animated: true, completion: nil)
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
  
  func error(error: String!, code: Int32, severity: Int32) {
    print("error = \(error),code = \(code),severity = \(severity)")
  }
  
  func putAlertMessage(alertProp:AnyObject!){
    let alertProp = alertProp as! [String:String]
    
    SVProgressHUD.dismiss()
    
    let myAlert = UIAlertController(title: alertProp["Title"]!, message: alertProp["Message"]!, preferredStyle: UIAlertControllerStyle.Alert)
    let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: { (action:UIAlertAction) -> Void in
      
    })
    
    myAlert.addAction(OKAction)
    self.presentViewController(myAlert, animated: true, completion: nil)
  }
}