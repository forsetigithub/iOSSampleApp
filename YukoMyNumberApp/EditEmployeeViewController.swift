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


class EditEmployeeViewController:UITableViewController,SQLClientDelegate{

  let realm = try! Realm()
  let client:SQLClient = SQLClient()
  
  // MARK: TableView定義
  private let sectionTitles = ["","家族情報",""]
  private let employeeItemLabels = [YukoMyNumberAppProperties.sharedInstance.EmployeeCodeLabelName,
                                    YukoMyNumberAppProperties.sharedInstance.EmployeeNameLabelName,
                                    YukoMyNumberAppProperties.sharedInstance.EmployeeMNLabelName]
  
  private var employeeItemData:[String] = [String]()
  private var familyItemData:[String] = [String]()

  private var employeeeditdata:EmployeeData = EmployeeData()
  
  private var myActivityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()

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
   
    myActivityIndicator.frame = CGRectMake(0, 0, 50, 50)
    myActivityIndicator.center = self.view.center
    myActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    
    self.view.addSubview(myActivityIndicator)
  
  }
  
  override func viewWillAppear(animated: Bool) {
    loadEmployeeData()
    self.tableView.reloadData()
  }
  
  /*
  セクションの数を返す.
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
    
    footerView.backgroundColor = UIColor.whiteColor()
    
    var tableButton:UIButton = UIButton()
    
    switch section {
      case 0: //本人
        tableButton = makeButtonInTableView("マイナンバーを登録",actionName: "getMyNumberBtn:")

        break
    
      case 1: //家族情報
        tableButton = makeButtonInTableView("家族を追加",actionName: "addFamilyBtn:")

        break
      
      case 2:
        tableButton = makeButtonInTableView("データを送信",actionName: "sendDataBtn:")

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
    
    switch indexPath.section {
      case 0:  //本人
        
        for subview in cell.contentView.subviews {
          switch subview.tag {
            case 1: //ラベル
              let label = subview as? UILabel
              label?.text = employeeItemLabels[indexPath.row] as? String
              break
            case 2: //値
              let label = subview as? UILabel
              if(indexPath.row == 2) {
                //マイナンバー取得状況
                cell.accessoryType = UITableViewCellAccessoryType.None
                
                if(employeeItemData[indexPath.row].characters.count ==
                    YukoMyNumberAppProperties.sharedInstance.MyNumberCharactersCount){
                  
                  label?.text = "取得済"
                  label?.textColor = UIColor.lightGrayColor()
                }else{
                  label?.text = "未取得"
                  label?.textColor = UIColor.redColor()
                }
              }else{
                label?.text = employeeItemData[indexPath.row]
              }
             
              break
            default:
              break
          }
        }
        
        break
      case 1:  //家族情報        
        for subview in cell.contentView.subviews{
          switch subview.tag {
            case 1: //氏名
              let label = subview as? UILabel
              label?.text = familyItemData[indexPath.row]
              
              break
            case 2:
              let label = subview as? UILabel
              label?.text?.removeAll()
              
            default:
              break
          }
        }
        
        break
      case 2:
        
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
    送信ボタン押下時処理
  */
  func sendDataBtn(sender:UIButton){
    
    let AlertView = UIAlertController(title: "確認", message: "送信します。よろしいですか？", preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    let OKAction = UIAlertAction(title: "送信", style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
      
      self.myActivityIndicator.startAnimating()
      self.uploadData()
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
  func uploadData(){
    
    let info = YukoMyNumberAppProperties.sharedInstance.ServerInfo
    
    client.connect(info["IPAddress"], username: info["UserName"], password: info["Password"],
      database: info["DataBaseName"]) { (success:Bool) -> Void in
      
      if(success){
        
        print("Connection Successed!")
        
        let sqlstring = "insert into T_Employee(SeqNo,EmployeeCode,EmployeeFamilyName,EmployeeFirstName,EmployeeMyNumber) values (NEWID(),'\(self.employeeeditdata.EmployeeCode)','\(self.employeeeditdata.FamilyName)','\(self.employeeeditdata.FirstName)','\(self.employeeeditdata.MyNumber)')"
        
        print(sqlstring)
        
        self.client.execute(sqlstring, completion: { (results:[AnyObject]!) -> Void in
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
    
    let families = realm.objects(EmployeeData).filter("EmployeeCode = '\(employeeeditdata.EmployeeCode)' and RSCode != '00'")
    for family in families{
      if(!family.DeleteFlag){
        familyItemData.append(family.FamilyName + "　" + family.FirstName)
      }
    }
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
