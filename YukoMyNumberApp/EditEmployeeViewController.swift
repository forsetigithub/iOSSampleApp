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
                                    YukoMyNumberAppProperties.sharedInstance.EmployeeJoinedDateLabelName,
                                    YukoMyNumberAppProperties.sharedInstance.EmployeeMNLabelName]
  
  private var employeeItemData:[String] = [String]()
  private var familyItemData:[EmployeeData] = [EmployeeData]()
  private var employeeeditdata:EmployeeData = EmployeeData()
  private var FirstCallFlag:Bool = true
  private var JoinedDateLabelTopFlag:Bool = false
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
    
    if(EmployeeEditData.PassCode.characters.count != 0){
      showPassCodeAlert()
    }else{
      FirstCallFlag = false
      loadEmployeeData()
    }
  }

  override func viewWillAppear(animated: Bool) {

    if(!FirstCallFlag){
      loadEmployeeData()
    }
    
    let uploadDataBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "tapUploadDataBarButtonItem:")
    
    let toolbarSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: self, action: nil)
    
    toolbarSpace.width = self.view.bounds.size.width / 2 - 27
    
    
    self.toolbarItems = [toolbarSpace,uploadDataBarButtonItem]
    self.navigationController?.toolbarHidden = false
   
  }
  
  func showPassCodeAlert(){
    
    let labelTitle = YukoMyNumberAppProperties.sharedInstance.PassCodeLabelName
    
    let myAlert:UIAlertController = UIAlertController(title: "\(labelTitle)入力", message: "\(labelTitle)(4桁)を入力してください", preferredStyle: UIAlertControllerStyle.Alert)
    
    let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
      
      if(self.InputPassCode != self.employeeeditdata.PassCode){
        let unmatchAlert = UIAlertController(title: "\(labelTitle)入力エラー", message: "\(labelTitle)が正しくありません。\n正しい\(labelTitle)を入力してください。", preferredStyle: UIAlertControllerStyle.Alert)
        
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
      }else if(indexPath.row == 2){
        performSegueWithIdentifier("showModifyJoinedDate", sender: self)
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
              if(employeeItemData.count == 0){
                continue
              }
              
              switch (indexPath.row){
                //マイナンバー取得状況
                case 3:
                  
                  cell.accessoryType = UITableViewCellAccessoryType.None
                  cell.userInteractionEnabled = false
                  
                  if(self.employeeeditdata.MyNumberCheckDigitResult){
                    
                    label?.text = "取得済"
                    label?.textColor = UIColor.lightGrayColor()
                  }else{
                    label?.text = "未取得"
                    label?.textColor = UIColor.redColor()
                  }
                  break
                
                default:
                  label?.text = self.employeeItemData[indexPath.row]

                  break
              }
              
              break
            default:
              break
          }
        }
        
        break
      case 1:  //家族情報        
        for subview in cell.contentView.subviews{
          
          let familyitem = familyItemData[indexPath.row]
          
          if(familyitem.MyNumberCheckDigitResult){
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
          }
          
          let label = subview as? UILabel
          
          switch subview.tag {
            case 1: //氏名
              label?.text = familyitem.FamilyName + "　" + familyitem.FirstName
              
              break
            case 2:
              label?.text?.removeAll()
      
              break
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
      
      //本人・家族のマイナンバーが全て登録されているかをチェックし、未登録の場合はメッセージを表示
      let numbercheck = self.realm.objects(EmployeeData).filter("EmployeeCode = '\(self.EmployeeEditData.EmployeeCode)' and MyNumber == ''")
      
      let SendAlertView = UIAlertController(title: "データ送信", message: "", preferredStyle: UIAlertControllerStyle.Alert)
      
      if(numbercheck.count == 0){
        
        SendAlertView.message = "データを送信します。よろしいですか？"
      }else{

        SendAlertView.message = "未登録のマイナンバーがあります。\n送信してもよろしいですか？"
      }
      
      let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
        
        self.uploadData(self.employeeeditdata)
        
      })
      
      let CancelAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
        
      })
      
      SendAlertView.addAction(OKAction)
      SendAlertView.addAction(CancelAction)
      
      self.presentViewController(SendAlertView, animated: true, completion: nil)
    }
    
    var title = "暗証番号を登録"
    if(self.employeeeditdata.PassCode.characters.count != 0){
      title = "暗証番号を変更"
    }
    
    let ChangePassword = UIAlertAction(title: title, style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
      self.performSegueWithIdentifier("showChangePassCode", sender: self)
    }
    
    let AlertCancelAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler: nil)
    
    AlertView.addAction(SendData)
    AlertView.addAction(ChangePassword)
    AlertView.addAction(AlertCancelAction)
    
    presentViewController(AlertView, animated: true, completion: nil)
    
  }
  
  /*
  * データをSQLServerへ登録する
  */
  func uploadData(uploaddata:EmployeeData){
    
    SVProgressHUD.showWithStatus("送信しています")
    
    let info = YukoMyNumberAppProperties.sharedInstance.ServerInfo
    
    client.connect(info["IPAddress"], username: info["UserName"], password: info["Password"],
      database: info["DataBaseName"]) { (success:Bool) -> Void in
      
      if(success){
        
        print("Connection Successed!")
    
        let list = self.realm.objects(EmployeeData).filter("EmployeeCode = '\(uploaddata.EmployeeCode)'").sorted("FamilySeqNo")
        
        var sqlstringlist:String = ""
        
        for data in list {

          let sqlstring = "insert into T_Employee(" +
            "SeqNo,EmployeeCode,RecKindNo,RelationCode,FamilyName,FirstName,MyNumber,TimeStamp" +
            ") values " +
            "(NEWID()," +
            "'\(data.EmployeeCode)'," +
            "2," +
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
            self.dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
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

    dateFormatter.dateFormat = "yyyy年MM月dd日"
    employeeItemData.append(dateFormatter.stringFromDate(employeeeditdata.JoinedDate))
    
    employeeItemData.append(employeeeditdata.MyNumber)
    
    familyItemData.removeAll()
    
    let families = realm.objects(EmployeeData).filter("EmployeeCode = '\(employeeeditdata.EmployeeCode)' and RSCode != '00' and DeleteFlag = false")
    for family in families{
      familyItemData.append(family)
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
    
    if(segue.identifier == "showModifyJoinedDate"){
      let dest = segue.destinationViewController as! ModifyJoinedDateViewController
      dest.EmployeeEditData = self.employeeeditdata
    }
    
    if(segue.identifier == "showEditFamily") {
      if(familyItemData.count > 0){
        let dest = segue.destinationViewController as! EditFamilyViewController
        let familydata = realm.objects(EmployeeData).filter("EmployeeCode = '\(employeeeditdata.EmployeeCode)' and RSCode != '00' and DeleteFlag = false")
        dest.FamilyItemData = familydata[(self.tableView.indexPathForSelectedRow!.row)]
      }
    }
    
    if(segue.identifier == "showChangePassCode"){
      let dest = segue.destinationViewController as? ChangePassCodeViewController
      dest?.EmployeeEditData = employeeeditdata
    }
  }
}
