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
import SQLClient

class EditEmployeeViewController:UITableViewController,SQLClientDelegate{

  let realm = try! Realm()
  let client:SQLClient = SQLClient()
  
  fileprivate let Properties = YukoMyNumberAppProperties.sharedInstance
  
  // MARK: TableView定義
  fileprivate var sectionTitles:[String]{
    get{
      let items:[String:String] = Properties.SectionItems["EditEmployee"] as! [String:String]
      return [items["EmployeeInfo"]!,items["FamilyInfo"]!,items["SendInfo"]!]
    }
  }

  fileprivate var employeeItemLabels:[String]{
    get{
      return [Properties.LabelItems["EmployeeCode"]!,
              Properties.LabelItems["EmployeeName"]!,
              Properties.LabelItems["EmployeeJoinedDate"]!,
              Properties.LabelItems["MyNumber"]!]
    }
  }
  
  fileprivate var employeeItemData:[String] = [String]()
  fileprivate var familyItemData:[EmployeeData] = [EmployeeData]()
  fileprivate var employeeeditdata:EmployeeData = EmployeeData()
  fileprivate var FirstCallFlag:Bool = true
  fileprivate var JoinedDateLabelTopFlag:Bool = false
  fileprivate var dateFormatter:DateFormatter = DateFormatter()

  fileprivate var InputPassCode:String?
  
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
    
    self.navigationItem.title = Properties.NavigationTitles["EditEmployeeViewController"]
  }

  override func viewWillAppear(_ animated: Bool) {

    if(!FirstCallFlag){
      loadEmployeeData()
    }
    
    let uploadDataBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: self, action: #selector(EditEmployeeViewController.tapUploadDataBarButtonItem(_:)))
    
    let toolbarSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: self, action: nil)
    
    toolbarSpace.width = self.view.bounds.size.width / 2 - Properties.ToolBarFixedSpaceSize
    
    
    self.toolbarItems = [toolbarSpace,uploadDataBarButtonItem]
    self.navigationController?.isToolbarHidden = false
   
  }
  
  func showPassCodeAlert(){
    
    let labelTitle:[String:String] = Properties.AlertMessages["InputPassCode"] as! [String:String]
    
    let myAlert:UIAlertController = UIAlertController(title: "\(labelTitle["Title"]!)", message: "\(labelTitle["Message"]!)(\(Properties.PassCodeCharactersCount)\(Properties.LabelItems["NumberOfDigits"]!))", preferredStyle: UIAlertController.Style.alert)
    
    let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action:UIAlertAction) -> Void in
      
      if(self.InputPassCode != self.employeeeditdata.PassCode){
        let labelTitle:[String:String] = self.Properties.AlertMessages["InputPassCodeError"] as! [String:String]
        
        let unmatchAlert = UIAlertController(title: "\(labelTitle["Title"]!)", message: "\(labelTitle["Message"]!)", preferredStyle: UIAlertController.Style.alert)
        
        let unmatchOK = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(action:UIAlertAction) -> Void in
          self.navigationController?.popViewController(animated: true)
        })
        
        unmatchAlert.addAction(unmatchOK)
        
        self.present(unmatchAlert, animated: true, completion: nil)
        
        return
        
      }
      
      SVProgressHUD.show()
      
      self.FirstCallFlag = false
      self.loadEmployeeData()
      
      SVProgressHUD.dismiss()
    })
    
    let CancelAction = UIAlertAction(title: Properties.AlertMessages["Cancel"] as? String, style: UIAlertAction.Style.cancel, handler: { (action:UIAlertAction) -> Void in
      self.navigationController?.popViewController(animated: true)
    })
    
    myAlert.addTextField(configurationHandler: { (textField:UITextField) -> Void in
      
      textField.isSecureTextEntry = true
      textField.keyboardType = UIKeyboardType.numberPad
      let myNotificationCenter = NotificationCenter.default
      
      myNotificationCenter.addObserver(self, selector: #selector(EditEmployeeViewController.changeTextField(_:)), name: UITextField.textDidChangeNotification, object: nil)
    })
    
    myAlert.addAction(OKAction)
    myAlert.addAction(CancelAction)
    
    self.present(myAlert, animated: true, completion: nil)
  }
  
  /*
  textFieldに変更が会った時に通知されるメソッド.
  */
  @objc internal func changeTextField (_ sender: Foundation.Notification) {
    let textField = sender.object as! UITextField
    
    self.InputPassCode = textField.text
    
    // 入力された文字を表示.
    print(textField.text ?? "")
  }
  
  
  /*
  セクションの数を返す
  */
  override func numberOfSections(in tableView: UITableView) -> Int {
    return sectionTitles.count
  }
  
  /*
  セクションのタイトルを返す.
  */
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sectionTitles[section]
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 44
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    switch(indexPath.section){
    case 0: //本人
      if(indexPath.row < 2){
        performSegue(withIdentifier: "showModifyEmployee", sender: self)
      }else if(indexPath.row == 2){
        performSegue(withIdentifier: "showModifyJoinedDate", sender: self)
      }
      
      break
    case 1: //家族情報
      performSegue(withIdentifier: "showEditFamily", sender: self)

      break
    default:
      break
    }

  }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footerView = UIView()
    footerView.autoresizingMask = [.flexibleLeftMargin,
                                  .flexibleRightMargin,
                                  .flexibleTopMargin,
                                  .flexibleBottomMargin]
    
    if(section != 2){
      footerView.backgroundColor = UIColor.white
    }
    
    var tableButton:UIButton = UIButton()
    
  
    switch section {
      case 0: //本人
        tableButton = makeButtonInTableView(Properties.ButtonTitles["RegisterMyNumber"]!,actionName: #selector(EditEmployeeViewController.getMyNumberBtn(_:)))

        break
    
      case 1: //家族情報
        tableButton = makeButtonInTableView(Properties.ButtonTitles["AddFamily"]!,actionName: #selector(EditEmployeeViewController.addFamilyBtn(_:)))

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
  func makeButtonInTableView(_ title:String,actionName action:Selector) -> UIButton{
    let makebtn = UIButton(type: UIButton.ButtonType.system)
    makebtn.setTitle(title, for: UIControl.State())
    makebtn.titleLabel?.font = UIFont(name: "System", size: Properties.ButtonInTableViewFontSize)
    makebtn.addTarget(self, action: action , for: UIControl.Event.touchUpInside)
    makebtn.frame = CGRect(x: self.view.center.x - 100, y: 5, width: 200, height: 30)

    return makebtn
  }
  
  /*
  テーブルに表示する配列の総数を返す.
  */
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
    
    cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
    
    switch indexPath.section {
      case 0:  //本人
        
        for subview in cell.contentView.subviews {
          let label = subview as? UILabel
          switch subview.tag {
            case 1: //ラベル
              label?.text = employeeItemLabels[indexPath.row]
              break
            case 2: //値
              if(employeeItemData.count == 0){
                continue
              }
              
              switch (indexPath.row){
                //マイナンバー取得状況
                case 3:
                  
                  cell.accessoryType = UITableViewCell.AccessoryType.none
                  cell.isUserInteractionEnabled = false
                  
                  if(self.employeeeditdata.MyNumberCheckDigitResult){
                    
                    label?.text = "取得済"
                    label?.textColor = UIColor.lightGray
                  }else{
                    label?.text = "未取得"
                    label?.textColor = UIColor.red
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
          
          let label = subview as? UILabel
          
          switch subview.tag {
            case 1: //氏名
              label?.text =  familyitem.FamilyName + "　" + familyitem.FirstName
              break

            case 2:
              label?.text?.removeAll()
      
              break

            case 3:
              let imageview = (subview as? UIImageView)!
              
              if(familyitem.MyNumberCheckDigitResult){
                imageview.image = UIImage(named: "checkmark.png")
              }else{
                imageview.image = UIImage(named: "")
              }
              break
            
            default:
              break
          }
        }
        
        break
      case 2: //送信状況
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.accessoryType = UITableViewCell.AccessoryType.none
        
        for subview in cell.contentView.subviews{
          let label = subview as? UILabel
          switch subview.tag{
            case 1:

              label?.text = "最終送信日時"
              break
            case 2:
              if(employeeItemData.count != 0){
                if(self.employeeeditdata.LastUploadDate.isEmpty){
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
  
  @objc func getMyNumberBtn(_ sender:UIButton){
    performSegue(withIdentifier: "showGetMyNumber", sender: self)
  }
  
  @objc func addFamilyBtn(_ sender:UIButton){
    performSegue(withIdentifier: "showAddNewFamily", sender: self)
  }
  
  /* 
  * UIToolbarのActionボタン押下時
  */
  @objc func tapUploadDataBarButtonItem(_ sender:UIButton){
    
    let AlertProp = Properties.AlertMessages["EditEmployeeActionSheet"] as! [String:AnyObject]
    let SendDataProp = AlertProp["SendData"] as! [String:String]
    
    let AlertView = UIAlertController(title: AlertProp["Title"]as? String, message: AlertProp["Message"] as? String, preferredStyle: UIAlertController.Style.actionSheet)
    
    let SendData = UIAlertAction(title: SendDataProp["Title"], style: UIAlertAction.Style.destructive) { (action:UIAlertAction) -> Void in
      
      //本人・家族のマイナンバーが全て登録されているかをチェックし、未登録の場合はメッセージを表示
      let numbercheck = self.realm.objects(EmployeeData.self).filter("EmployeeCode = '\(self.EmployeeEditData.EmployeeCode)' and MyNumber == ''")
      
      let SendAlertView = UIAlertController(title: SendDataProp["Title"], message: "", preferredStyle: UIAlertController.Style.alert)
      
      if(numbercheck.count == 0){
        
        SendAlertView.message = "データを送信します。よろしいですか？"
      }else{

        SendAlertView.message = "未登録のマイナンバーがあります。\n送信してもよろしいですか？"
      }
      
      let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action:UIAlertAction) -> Void in
        
        self.uploadData(self.employeeeditdata)
        
      })
      
      let CancelAction = UIAlertAction(title: self.Properties.ButtonTitles["Cancel"], style: UIAlertAction.Style.cancel, handler: { (action:UIAlertAction) -> Void in
        
      })
      
      SendAlertView.addAction(OKAction)
      SendAlertView.addAction(CancelAction)
      
      self.present(SendAlertView, animated: true, completion: nil)
    }
    
    var title = "\(Properties.LabelItems["PassCode"]!)を登録"
    if(self.employeeeditdata.PassCode.characters.count != 0){
      title = "\(Properties.LabelItems["PassCode"]!)を変更"
    }
    
    let ChangePassword = UIAlertAction(title: title, style: UIAlertAction.Style.default) { (action:UIAlertAction) -> Void in
      self.performSegue(withIdentifier: "showChangePassCode", sender: self)
    }
    
    let AlertCancelAction = UIAlertAction(title: self.Properties.AlertMessages["Cancel"] as? String, style: UIAlertAction.Style.cancel, handler: nil)
    
    AlertView.addAction(SendData)
    AlertView.addAction(ChangePassword)
    AlertView.addAction(AlertCancelAction)
    
    present(AlertView, animated: true, completion: nil)
    
  }
  
  /*
  * データをSQLServerへ登録する
  */
  func uploadData(_ uploaddata:EmployeeData){
    
    SVProgressHUD.show(withStatus: "送信しています")
    
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    let info = Properties.ServerInfo
    
    client.connect(info["IPAddress"], username: info["UserName"], password: info["Password"],
      database: info["DataBaseName"]) { (success:Bool) -> Void in
      
      if(success){
        
        print("Connection Successed!")
    
        let list = self.realm.objects(EmployeeData.self).filter("EmployeeCode = '\(uploaddata.EmployeeCode)'").sorted(byKeyPath: "FamilySeqNo")
        
        var sqlstringlist:String = ""
        
        let timestamp = self.dateFormatter.string(from: Date())
        
        for data in list {

          let sqlstring = "insert into T_Employee(" +
            "SeqNo,EmployeeCode,RecKindNo,RelationCode,FamilyName,FirstName,JoinedDate,MyNumber,TimeStamp,MNRegisterMode" +
            ") values " +
            "(NEWID()," +
            "'\(data.EmployeeCode)'," +
            "2," +
            "'\(data.RSCode)'," +
            "'\(data.FamilyName)'," +
            "'\(data.FirstName)'," +
            "'\(self.dateFormatter.string(from: data.JoinedDate))'," +
            "'\(data.MyNumber.replacingOccurrences(of: " ", with: ""))'," +
            "'\(timestamp)'," +
            "\(data.MNRegisterMode)" +
          ")"

          sqlstringlist = sqlstringlist + sqlstring
        }
        
        print(sqlstringlist)
        
        self.client.execute(sqlstringlist, completion: { (results:[Any]?) -> Void in
          
#if DEBUG
  print("timestamp_before = \(timestamp)")
  //timestamp = self.dateFormatter.stringFromDate(NSDate(timeIntervalSinceNow: 1))
  print("timestamp_after = \(timestamp)")
#else
#endif

          let checksqlstring = "select * from T_Employee where EmployeeCode = '\((list.first?.EmployeeCode)!)' and TimeStamp = '\(timestamp)'"
          
          print(checksqlstring)
          
          var AlertProp = self.Properties.AlertMessages["SendOK"] as! [String:String]

          self.client.execute(checksqlstring, completion: { (results : [Any]?) -> Void in
            
            SVProgressHUD.dismiss()
            
            if((results?[0] as AnyObject).count != 0){
              
              try! self.realm.write({ () -> Void in
                self.dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                self.employeeeditdata.LastUploadDate = self.dateFormatter.string(from: Date())
              })
              
              self.client.disconnect()
              
              let messageAlert = UIAlertController(title:AlertProp["Title"]! , message: AlertProp["Message"]!, preferredStyle: UIAlertController.Style.alert)
              
              let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action:UIAlertAction) -> Void in
                
                self.navigationController?.popViewController(animated: true)
              })
              
              messageAlert.addAction(OKAction)
              
              self.present(messageAlert, animated: true, completion: nil)
              
            }else{
              AlertProp = self.Properties.AlertMessages["SendError"] as! [String:String]

              let messageAlert = UIAlertController(title:AlertProp["Title"]! , message: AlertProp["Message"]!, preferredStyle: UIAlertController.Style.alert)
              
              let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: { (action:UIAlertAction) -> Void in
                
              })
              
              messageAlert.addAction(OKAction)
              self.present(messageAlert, animated: true, completion: nil)
  
            }
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
  
  
  @objc func error(_ error: String!, code: Int32, severity: Int32) {
    print("error=\(error),code=\(code)")
  }
  
  func loadEmployeeData(){
    
    employeeItemData.removeAll()
    employeeItemData.append(employeeeditdata.EmployeeCode)
    employeeItemData.append(employeeeditdata.FamilyName + "　" +
      employeeeditdata.FirstName)

    dateFormatter.dateFormat = "yyyy年MM月dd日"
    employeeItemData.append(dateFormatter.string(from: employeeeditdata.JoinedDate as Date))
    
    employeeItemData.append(employeeeditdata.MyNumber)
    
    familyItemData.removeAll()
    
    let families = realm.objects(EmployeeData.self).filter("EmployeeCode = '\(employeeeditdata.EmployeeCode)' and RSCode != '00' and DeleteFlag = false")
    for family in families{
      familyItemData.append(family)
    }

    try! realm.write({ () -> Void in
      let delitem = realm.objects(EmployeeData.self).filter("EmployeeCode = '\(self.employeeeditdata.EmployeeCode)' and RSCode != '00' and DeleteFlag = true")
      self.realm.delete(delitem)
    })

    self.tableView.reloadData()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if(segue.identifier == "showGetMyNumber") {
      let dest = segue.destination as! GetMyNumberViewController

      dest.MyNumberEditData = employeeeditdata
    }
    
    if(segue.identifier == "showAddNewFamily"){
      let dest = segue.destination as! RegisterFamilyViewController
      dest.EmployeeEditData = employeeeditdata
    }
    
    if(segue.identifier == "showModifyEmployee"){
      let dest = segue.destination as! ModifyEmployeeDataViewController
      
      switch (self.tableView.indexPathForSelectedRow!.row){
        case 0:
          dest.navigationItem.title = Properties.LabelItems["EmployeeCode"]
          dest.ModifyMode = ModifyEmployeeDataViewController.ModifyModeEnum.employee
          break
        case 1:
          dest.navigationItem.title = Properties.LabelItems["EmployeeName"]
           dest.ModifyMode = ModifyEmployeeDataViewController.ModifyModeEnum.name
          break
        default:
          break
      }
      
      dest.EmployeeEditData = employeeeditdata
    
    }
    
    if(segue.identifier == "showModifyJoinedDate"){
      let dest = segue.destination as! ModifyJoinedDateViewController
      dest.EmployeeEditData = self.employeeeditdata
    }
    
    if(segue.identifier == "showEditFamily") {
      if(familyItemData.count > 0){
        let dest = segue.destination as! EditFamilyViewController
        let familydata = realm.objects(EmployeeData.self).filter("EmployeeCode = '\(employeeeditdata.EmployeeCode)' and RSCode != '00' and DeleteFlag = false")
        dest.FamilyItemData = familydata[(self.tableView.indexPathForSelectedRow!.row)]
      }
    }
    
    if(segue.identifier == "showChangePassCode"){
      let dest = segue.destination as! ChangePassCodeViewController
      dest.EmployeeEditData = self.employeeeditdata
    }
  }
}
