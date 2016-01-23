//
//  RegisterEditViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/05.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import UIKit
import RealmSwift
import Foundation
import SVProgressHUD

class EditEmployeeViewController:UITableViewController,SQLClientDelegate{

  let realm = try! Realm()
  let client:SQLClient = SQLClient()
  
  // MARK: TableView定義
  private let sectionTitles = ["本人情報","家族情報","送信情報"]
  private let employeeItemLabels = [YukoMyNumberAppProperties.sharedInstance.EmployeeCodeLabelName,
                                    YukoMyNumberAppProperties.sharedInstance.EmployeeNameLabelName,
                                    YukoMyNumberAppProperties.sharedInstance.EmployeeMNLabelName]
  
  private var employeeItemData:[String] = [String]()
  private var familyItemData:[String] = [String]()
  private var employeeeditdata:EmployeeData = EmployeeData()
  private var FirstCallFlag:Bool = true
  private let dateFormatter:NSDateFormatter = NSDateFormatter()

  private var InputPassCode:String?
  
  var EmployeeEditData:EmployeeData{
    set(newValue){
      employeeeditdata = newValue
    }
    get{
      return employeeeditdata
    }
  }
  
  // MARK: - Table View
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  
    client.delegate = self
  
    dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    
    showPassCodeAlert()
    
  }

  override func viewWillAppear(animated: Bool) {

    if(!FirstCallFlag){
      loadEmployeeData()
    }
    
    let uploadDataBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "tapUploadDataBarButtonItem:")
    
    let toolbarSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: self, action: nil)
    
    toolbarSpace.width = self.view.bounds.size.width / 2 - 27
    
    
    self.toolbarItems = [toolbarSpace,uploadDataBarButtonItem]
    self.navigationController?.setToolbarHidden(false, animated: false)
   
  }
  
  func showPassCodeAlert(){
    let myAlert:UIAlertController = UIAlertController(title: "暗証番号入力", message: "暗証番号(4桁)を入力してください", preferredStyle: UIAlertControllerStyle.Alert)
    
    let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
      
      if(self.InputPassCode != self.employeeeditdata.PassCode){
        let unmatchAlert = UIAlertController(title: "暗証番号入力エラー", message: "暗証番号が正しくありません。\n正しい暗証番号を入力してください。", preferredStyle: UIAlertControllerStyle.Alert)
        
        let unmatchOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) -> Void in
          self.navigationController?.popViewControllerAnimated(true)
        })
        
        unmatchAlert.addAction(unmatchOK)
        
        self.presentViewController(unmatchAlert, animated: true, completion: nil)
        
        return
        
      }
      
      SVProgressHUD.show()
      
      self.FirstCallFlag = false
      self.loadEmployeeData()
      
      SVProgressHUD.dismiss()
    })
    
    let CancelAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
      self.navigationController?.popViewControllerAnimated(true)
    })
    
    myAlert.addTextFieldWithConfigurationHandler({ (textField:UITextField) -> Void in
      
      textField.secureTextEntry = true
      textField.keyboardType = UIKeyboardType.NumberPad
      let myNotificationCenter = NSNotificationCenter.defaultCenter()
      
      myNotificationCenter.addObserver(self, selector: "changeTextField:", name: UITextFieldTextDidChangeNotification, object: nil)
    })
    
    myAlert.addAction(OKAction)
    myAlert.addAction(CancelAction)
    
    self.presentViewController(myAlert, animated: true, completion: nil)
  }
  
  /*
  textFieldに変更が会った時に通知されるメソッド.
  */
  internal func changeTextField (sender: NSNotification) {
    let textField = sender.object as! UITextField
    
    self.InputPassCode = textField.text
    
    // 入力された文字を表示.
    print(textField.text)
  }
  
  
  /*
  セクションの数を返す
  */
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return sectionTitles.count
  }
  
  /*
  セクションのタイトルを返す.
  */
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sectionTitles[section]
  }
  
  override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 44
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    switch(indexPath.section){
    case 0: //本人
      if(indexPath.row < 2){
        performSegueWithIdentifier("showModifyEmployee", sender: self)
      }
      
      break
    case 1: //家族情報
      performSegueWithIdentifier("showEditFamily", sender: self)

      break
    default:
      break
    }

  }
  
  override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footerView = UIView()
    footerView.autoresizingMask = [.FlexibleLeftMargin,
                                  .FlexibleRightMargin,
                                  .FlexibleTopMargin,
                                  .FlexibleBottomMargin]
    
    if(section != 2){
      footerView.backgroundColor = UIColor.whiteColor()
    }
    
    var tableButton:UIButton = UIButton()
    
    switch section {
      case 0: //本人
        tableButton = makeButtonInTableView("マイナンバーを登録",actionName: "getMyNumberBtn:")

        break
    
      case 1: //家族情報
        tableButton = makeButtonInTableView("家族を追加",actionName: "addFamilyBtn:")

        break
      
      case 2:
        //tableButton = makeButtonInTableView("データを送信",actionName: "sendDataBtn:")
        break
      
      default:
        break
    }
    
    footerView.addSubview(tableButton)
    
    return footerView
  }
  
  /* 
    テーブルに表示させるボタンを作成する
  */
  func makeButtonInTableView(title:String,actionName action:Selector) -> UIButton{
    let makebtn = UIButton(type: UIButtonType.System)
    makebtn.setTitle(title, forState: UIControlState.Normal)
    makebtn.titleLabel?.font = UIFont(name: "System", size: YukoMyNumberAppProperties.sharedInstance.ButtonInTableViewFontSize)
    makebtn.addTarget(self, action: action , forControlEvents: UIControlEvents.TouchUpInside)
    makebtn.frame = CGRectMake(self.view.center.x - 100, 5, 200, 30)

    return makebtn
  }
  
  /*
  テーブルに表示する配列の総数を返す.
  */
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var rowcount = 0
    switch section {
      case 0: //本人
        rowcount = employeeItemLabels.count
        break
      case 1: //家族情報
        rowcount = familyItemData.count
        break
      case 2: //送信状況
        rowcount = 1
        break
      default:
        break
    }
    
    return rowcount
  }
  
  /*
  Cellに値を設定する.
  */
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath)
    
    cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    
    switch indexPath.section {
      case 0:  //本人
        
        for subview in cell.contentView.subviews {
          let label = subview as? UILabel
          switch subview.tag {
            case 1: //ラベル
              label?.text = employeeItemLabels[indexPath.row] as? String
              break
            case 2: //値
              
              if(indexPath.row == 2) {
                //マイナンバー取得状況
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.userInteractionEnabled = false
                
                if(employeeItemData.count != 0 && self.employeeeditdata.MyNumberCheckDigitResult){
                  
                  label?.text = "取得済"
                  label?.textColor = UIColor.lightGrayColor()
                }else{
                  label?.text = "未取得"
                  label?.textColor = UIColor.redColor()
                }
              }else{
                if(self.employeeItemData.count != 0){
                  label?.text = self.employeeItemData[indexPath.row]
                }
              }
        
              break
            default:
              break
          }
        }
        
        break
      case 1:  //家族情報        
        for subview in cell.contentView.subviews{

          let label = subview as? UILabel
          
          switch subview.tag {
            case 1: //氏名
              label?.text = familyItemData[indexPath.row]
              
              break
            case 2:
              label?.text?.removeAll()
              
            default:
              break
          }
        }
        
        break
      case 2: //送信状況
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.accessoryType = UITableViewCellAccessoryType.None
        
        for subview in cell.contentView.subviews{
          let label = subview as? UILabel
          switch subview.tag{
            case 1:

              label?.text = "最終送信日時"
              break
            case 2:
              if(employeeItemData.count != 0){
                if(self.employeeeditdata.LastUploadDate.characters.count == 0){
                  label?.text = "未送信"
                }else{
                  label?.text = self.employeeeditdata.LastUploadDate
                }
              }
              
              break
            default:
              break
          }
        }
        break
      default:
        break
    }
    
    return cell
  }
  
  func getMyNumberBtn(sender:UIButton){
    performSegueWithIdentifier("showGetMyNumber", sender: self)
  }
  
  func addFamilyBtn(sender:UIButton){
    performSegueWithIdentifier("showAddNewFamily", sender: self)
  }
  
  /* 
  * UIToolbarのActionボタン押下時
  */
  func tapUploadDataBarButtonItem(sender:UIButton){
    let AlertView = UIAlertController(title: "メニューを選択してください", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    let SendData = UIAlertAction(title: "データを送信", style: UIAlertActionStyle.Destructive) { (action:UIAlertAction) -> Void in
      
      let SendAlertView = UIAlertController(title:"データ送信",message: "データを送信します。よろしいですか？",preferredStyle: UIAlertControllerStyle.Alert)
      
      let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
        //self.sendDataBtn(sender)
        self.uploadData(self.employeeeditdata)
      })
      
      let CancelAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
        
      })
      
      SendAlertView.addAction(OKAction)
      SendAlertView.addAction(CancelAction)
      
      self.presentViewController(SendAlertView, animated: true, completion: nil)
    }
    
    let ChangePassword = UIAlertAction(title: "暗証番号を変更", style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
      self.performSegueWithIdentifier("showChangePassCode", sender: self)
    }
    
    let AlertCancelAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler: nil)
    
    AlertView.addAction(SendData)
    AlertView.addAction(ChangePassword)
    AlertView.addAction(AlertCancelAction)
    
    presentViewController(AlertView, animated: true, completion: nil)
    
  }
  
  /* 
    送信ボタン押下時処理
  */
  func sendDataBtn(sender:UIButton){
    
    let AlertView = UIAlertController(title: "データを送信", message: "データを送信します。よろしいですか？", preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    let OKAction = UIAlertAction(title: "送信", style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
      
      self.uploadData(self.employeeeditdata)
      
    }
    
    let CancelAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel) { (cancel:UIAlertAction) -> Void in
      
    }
    
    AlertView.addAction(OKAction)
    AlertView.addAction(CancelAction)
    
    presentViewController(AlertView, animated: true, completion: nil)
  }
  
  /*
  * データをSQLServerへ登録する
  */
  func uploadData(uploaddata:EmployeeData){
    
    SVProgressHUD.showWithStatus("送信中・・・")
    
    let info = YukoMyNumberAppProperties.sharedInstance.ServerInfo
    
    client.connect(info["IPAddress"], username: info["UserName"], password: info["Password"],
      database: info["DataBaseName"]) { (success:Bool) -> Void in
      
      if(success){
        
        print("Connection Successed!")
    
        let list = self.realm.objects(EmployeeData).filter("EmployeeCode = '\(uploaddata.EmployeeCode)'").sorted("FamilySeqNo")
        
        var sqlstringlist:String = ""
        
        for data in list {

          let sqlstring = "insert into T_Employee(" +
            "SeqNo,EmployeeCode,RelationCode,FamilyName,FirstName,MyNumber,TimeStamp" +
            ") values " +
            "(NEWID()," +
            "'\(data.EmployeeCode)'," +
            "'\(data.RSCode)'," +
            "'\(data.FamilyName)'," +
            "'\(data.FirstName)'," +
            "'\(data.MyNumber.stringByReplacingOccurrencesOfString(" ", withString: ""))'," +
            "SYSDATETIME()" +
          ")"

          sqlstringlist = sqlstringlist + sqlstring
        }
        
        print(sqlstringlist)
        
        self.client.execute(sqlstringlist, completion: { (results:[AnyObject]!) -> Void in
          
          self.client.disconnect()
          
          try! self.realm.write({ () -> Void in
            self.employeeeditdata.LastUploadDate = self.dateFormatter.stringFromDate(NSDate())
          })
          
          SVProgressHUD.dismiss()
          
          let messageAlert = UIAlertController(title: "送信完了", message: "送信しました", preferredStyle: UIAlertControllerStyle.Alert)
          
          let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
            
            self.navigationController?.popViewControllerAnimated(true)
          })
          
          messageAlert.addAction(OKAction)
          
          self.presentViewController(messageAlert, animated: true, completion: nil)
          
          print("Disconnected")
        })
        
      }else{
        SVProgressHUD.dismiss()
        print("Error Connect")
        return
      }
    }
  
  }
  
  
  @objc func error(error: String!, code: Int32, severity: Int32) {
    print("error=\(error),code=\(code)")
  }
  
  func loadEmployeeData(){
    
    employeeItemData.removeAll()
    employeeItemData.append(employeeeditdata.EmployeeCode)
    employeeItemData.append(employeeeditdata.FamilyName + "　" +
      employeeeditdata.FirstName)
    employeeItemData.append(employeeeditdata.MyNumber)
    
    familyItemData.removeAll()
    
    let families = realm.objects(EmployeeData).filter("EmployeeCode = '\(employeeeditdata.EmployeeCode)' and RSCode != '00' and DeleteFlag = false")
    for family in families{
      familyItemData.append(family.FamilyName + "　" + family.FirstName)
    }

    try! realm.write({ () -> Void in
      let delitem = realm.objects(EmployeeData).filter("EmployeeCode = '\(self.employeeeditdata.EmployeeCode)' and RSCode != '00' and DeleteFlag = true")
      self.realm.delete(delitem)
    })

    self.tableView.reloadData()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if(segue.identifier == "showGetMyNumber") {
      let dest = segue.destinationViewController as! GetMyNumberViewController

      dest.MyNumberEditData = employeeeditdata
    }
    
    if(segue.identifier == "showAddNewFamily"){
      let dest = segue.destinationViewController as! RegisterFamilyViewController
      dest.EmployeeEditData = employeeeditdata
    }
    
    if(segue.identifier == "showModifyEmployee"){
      let dest = segue.destinationViewController as! ModifyEmployeeDataViewController
      
      switch (self.tableView.indexPathForSelectedRow!.row){
        case 0:
          dest.navigationItem.title = "社員番号"
          dest.ModifyMode = ModifyEmployeeDataViewController.ModifyModeEnum.Employee
          break
        case 1:
          dest.navigationItem.title = "氏名"
           dest.ModifyMode = ModifyEmployeeDataViewController.ModifyModeEnum.Name
          break
        default:
          break
      }
      
      dest.EmployeeEditData = employeeeditdata
    
    }
    
    if(segue.identifier == "showEditFamily") {
      if(familyItemData.count > 0){
        let dest = segue.destinationViewController as! EditFamilyViewController
        let familydata = realm.objects(EmployeeData).filter("EmployeeCode = '\(employeeeditdata.EmployeeCode)' and RSCode != '00' and DeleteFlag = false")
        dest.FamilyItemData = familydata[(self.tableView.indexPathForSelectedRow!.row)]
      }
    }
  }
}
