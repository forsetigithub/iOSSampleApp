//
//  RegisterEditViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/05.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import UIKit

class RegisterEditViewController:UITableViewController{

  // MARK: TableView定義
  private let sectionTitles = ["","家族情報"]
  private let employeeItemLabels = [YukoMyNumberAppProperties.sharedInstance.EmployeeCodeLabelName,
                                    YukoMyNumberAppProperties.sharedInstance.EmployeeNameLabelName,
                                    YukoMyNumberAppProperties.sharedInstance.EmployeeMNLabelName]
  
  private var employeeItemData:[String] = [String]()

  
  private var employeeeditdata:EmployeeData = EmployeeData()

  var EmployeeEditData:EmployeeData{
    set(newValue){
      employeeeditdata = newValue
    }
    get{
      return employeeeditdata
    }
  }
  
  @IBOutlet weak var EmployeeCodeTextField: UITextField!
  @IBOutlet weak var EmployeeNameTextField: UITextField!
  @IBOutlet weak var EmployeeMNTextField: UITextField!
  
  
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
  
  override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footerView = UIView()
    
    footerView.backgroundColor = UIColor.whiteColor()
    
    switch section {
      case 0: //本人
        let getMyNumberBtn = UIButton()
        getMyNumberBtn.setTitle("マイナンバーを取得", forState: UIControlState.Normal)
        getMyNumberBtn.addTarget(self, action: "getMyNumberBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        getMyNumberBtn.frame = CGRectMake(self.view.bounds.width / 2 - 90, 5, 200, 30)
        getMyNumberBtn.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        footerView.addSubview(getMyNumberBtn)
        break
    
      case 1: //家族情報
        let addFamilyBtn = UIButton()
        addFamilyBtn.setTitle("家族を追加", forState: UIControlState.Normal)
        addFamilyBtn.addTarget(self, action: "addFamilyBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        addFamilyBtn.frame = CGRectMake(self.view.bounds.width / 2 - 90, 5, 200, 30)
        addFamilyBtn.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        footerView.addSubview(addFamilyBtn)
      default:
        break
    }
    
    return footerView
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
                if(employeeItemData[indexPath.row].characters.count == YukoMyNumberAppProperties.sharedInstance.MyNumberCharactersCount){
                  label?.text = "取得済"
                  label?.textColor = UIColor.blueColor()
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
    print("addFamily...")
  }
  
  func loadEmployeeData(){
    employeeItemData.removeAll()
    employeeItemData.append(employeeeditdata.EmployeeCode)
    employeeItemData.append(employeeeditdata.EmployeeName)
    employeeItemData.append(employeeeditdata.EmployeeMN)

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
  }
  
  @IBAction func tapGetMyNumber(sender: UIButton) {
    performSegueWithIdentifier("showGetMyNumber", sender: self)
  
  }
  
  
  
  
}
