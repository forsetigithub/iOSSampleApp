//
//  RegisterEditViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/05.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import UIKit
import RealmSwift

class EditEmployeeViewController:UITableViewController{

  
  let realm = try! Realm()
  
  // MARK: TableView定義
  private let sectionTitles = ["","家族情報",""]
  private let employeeItemLabels = [YukoMyNumberAppProperties.sharedInstance.EmployeeCodeLabelName,
                                    YukoMyNumberAppProperties.sharedInstance.EmployeeNameLabelName,
                                    YukoMyNumberAppProperties.sharedInstance.EmployeeMNLabelName]
  
  private var employeeItemData:[String] = [String]()
  private var familyItemData:[String] = [String]()

  
  private var employeeeditdata:EmployeeData = EmployeeData()

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
        tableButton = makeButtonInTableView("マイナンバーを取得",actionName: "getMyNumberBtn:")

        break
    
      case 1: //家族情報
        tableButton = makeButtonInTableView("家族を追加",actionName: "addFamilyBtn:")

        break
      
      case 2:
        tableButton = makeButtonInTableView("データ送信",actionName: "sendDataBtn:")

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
    makebtn.titleLabel?.font = UIFont(name: "System", size: 17)
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
        rowcount = employeeeditdata.families.count
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
  
  func sendDataBtn(sender:UIButton){
    print("データ送信・・・")
  }
  
  func loadEmployeeData(){
    employeeItemData.removeAll()
    employeeItemData.append(employeeeditdata.EmployeeCode)
    employeeItemData.append(employeeeditdata.EmployeeFamilyName + "　" +
      employeeeditdata.EmployeeFirstName)
    employeeItemData.append(employeeeditdata.EmployeeMN)
    
    familyItemData.removeAll()
    for family in employeeeditdata.families{
      familyItemData.append(family.FamilyName + "　" + family.FirstName)
    }

  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if(segue.identifier == "showGetMyNumber") {
      let dest = segue.destinationViewController as! GetMyNumberTestViewController
      dest.EmployeeEditData = employeeeditdata
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
        dest.FamilyItemData = employeeeditdata.families[(self.tableView.indexPathForSelectedRow!.row)]
      }
    }
  }
}
