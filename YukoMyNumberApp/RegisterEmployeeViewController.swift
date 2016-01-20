//
//  RegisterAddNewViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/06.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import UIKit
import RealmSwift

class RegisterEmployeeViewController : UITableViewController,UITextFieldDelegate {
  
  let realm = try! Realm()
  let client:SQLClient = SQLClient()
  
  // MARK: - Table View  
  @IBOutlet weak var EmployeeCode: UITextField!
  @IBOutlet weak var EmployeeFamilyName: UITextField!
  @IBOutlet weak var EmployeeFirstName: UITextField!
  @IBOutlet weak var EmployeeJoinedDateLabel: UILabel!
  
  
  let myActivityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
  
  var JoinedDate:NSDate?
  let formatter = NSDateFormatter()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    EmployeeCode.delegate = self
    EmployeeFamilyName.delegate = self
    EmployeeFirstName.delegate = self
    
    self.navigationItem.title = "新規登録"
    formatter.dateFormat = "yyyy年 MM月 dd日"
    
    myActivityIndicator.frame = CGRectMake(0, 0, 50, 50)
    myActivityIndicator.center = self.view.center
    myActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    
    self.view.addSubview(myActivityIndicator)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  
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

  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }

  
  @IBAction func tapRegisterButton(sender: UIBarButtonItem) {
    
    try! realm.write({ () -> Void in
      let NewEmployeeData = EmployeeData()
      NewEmployeeData.EmployeeCode = self.EmployeeCode.text!
      NewEmployeeData.FamilyName = self.EmployeeFamilyName.text!
      NewEmployeeData.FirstName = self.EmployeeFirstName.text!
      NewEmployeeData.FamilySeqNo = 0
      NewEmployeeData.RSCode = "00"
      NewEmployeeData.JoinedDate = self.JoinedDate!
      NewEmployeeData.CreateDateTime = NSDate()
      self.realm.add(NewEmployeeData)
      
      uploadData(NewEmployeeData)
      
      self.performSegueWithIdentifier("showRegisterList", sender: self)
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
    
    myActivityIndicator.startAnimating()
    
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
            self.myActivityIndicator.stopAnimating()
            
            let messageAlert = UIAlertController(title: "送信完了", message: "送信しました", preferredStyle: UIAlertControllerStyle.Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
              
              self.navigationController?.popViewControllerAnimated(true)
            })
            
            messageAlert.addAction(OKAction)
            
            self.presentViewController(messageAlert, animated: true, completion: nil)
            
            print("Disconnected")
          })
          
        }else{
          self.myActivityIndicator.stopAnimating()
          print("Error Connect")
          return
        }
    }
    
  }

  
}