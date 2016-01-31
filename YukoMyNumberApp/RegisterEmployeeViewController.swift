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
  
  private let Properties = YukoMyNumberAppProperties.sharedInstance
  
  // MARK: - Table View
  @IBOutlet weak var EmployeeCode: UITextField!
  @IBOutlet weak var EmployeeFamilyName: UITextField!
  @IBOutlet weak var EmployeeFirstName: UITextField!
  @IBOutlet weak var EmployeeJoinedDateLabel: UILabel!
  
  @IBOutlet weak var JoinedDatePicker: UIDatePicker!
  @IBOutlet weak var PassCodeTextField: UITextField!
  @IBOutlet weak var RePassCodeTextField: UITextField!
  
  
  var JoinedDate:NSDate?
  let formatter = NSDateFormatter()
  
  private var InputPassCode:String? //暗証番号(初回)
  private var InitialJoinedDateLabel:String!
  
  private var JoinedDateTappedFlag:Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    EmployeeCode.delegate = self
    EmployeeFamilyName.delegate = self
    EmployeeFirstName.delegate = self
    PassCodeTextField.delegate = self
    RePassCodeTextField.delegate = self
    
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
  
    if((textField.tag == 4 || textField.tag == 5) &&
      textField.text?.characters.count != 0 && textField.text?.characters.count != Properties.PassCodeCharactersCount){
    
        let myAlert = UIAlertController(title: "", message: "暗証番号は\(Properties.PassCodeCharactersCount)桁で入力してください。", preferredStyle: UIAlertControllerStyle.Alert)
        
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
        
      //暗証番号の桁数しか入力できないようにする
      case 4,5:

        if(str.characters.count > Properties.PassCodeCharactersCount){
          
          return false
          
        }else if(textField.tag == 2 && str.characters.count ==
          Properties.PassCodeCharactersCount && str != self.InputPassCode){
            
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
    if(self.EmployeeCode.text?.isEmpty == true ||
      self.EmployeeFamilyName.text?.isEmpty == true ||
      self.EmployeeFirstName.text?.isEmpty == true  ||
      self.EmployeeJoinedDateLabel.text == self.InitialJoinedDateLabel ){
        
        let requiredvalid:[String:String] = Properties.AlertMessages["RequiredItemValidError"] as! [String:String]
        
        let myAlert = UIAlertController(title: requiredvalid["Title"], message: requiredvalid["Message"], preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
          
         
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
    
    NewEmployeeData.PassCode = self.PassCodeTextField.text!
    NewEmployeeData.CreateDateTime = NSDate()
    
#if DEBUG
    try! realm.write({ () -> Void in
      realm.add(NewEmployeeData)
      self.dismissViewControllerAnimated(true, completion: nil)
    })

#else
    uploadData(NewEmployeeData)
#endif

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
          
          let sqlstring = "insert into T_Employee(" +
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
            ")"

          print(sqlstring)

          self.client.execute(sqlstring, completion: { (results:[AnyObject]!) -> Void in
            
            let checksqlstring = "select * from T_Employee where EmployeeCode = '\(uploaddata.EmployeeCode)' and TimeStamp = '\(timestamp)'"
            
            print(checksqlstring)
            
            self.client.execute(checksqlstring, completion: { (results:[AnyObject]!) -> Void in
              
              SVProgressHUD.dismiss()
              
              if(results[0].count != 0){
                //データ登録
                try! self.realm.write({ () -> Void in
                  self.realm.add(uploaddata)
                })
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
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
            })
          })
          
        }else{
          SVProgressHUD.dismiss()
          print("Error Connect")
          return
        }
    }
  }
}