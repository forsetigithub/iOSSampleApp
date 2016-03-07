//
//  ViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/05.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD


class RegisteredListViewController: UITableViewController {
  
  let realm = try! Realm()
  
  private let Properties = YukoMyNumberAppProperties.sharedInstance
  private let employeefilter = NSPredicate(format: "RSCode = '00'")
  
  private var isConnectedFlg:Bool = false
  
  // MARK: - Table View
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = Properties.NavigationTitles["RegisteredListViewController"]
    self.navigationItem.leftBarButtonItem = editButtonItem()
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Properties.ButtonTitles["AddNew"], style: UIBarButtonItemStyle.Plain, target: self, action: "tapAddNewButton:")
    
    let infobutton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "tapVersionInfo:")
    
    let barspace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
    barspace.width = self.view.bounds.size.width / 2 - Properties.ToolBarFixedSpaceSize
    self.toolbarItems = [barspace,infobutton]
    self.navigationController?.toolbarHidden = false
  }

  override func viewWillLayoutSubviews() {

  }
  
  override func viewDidAppear(animated: Bool) {
  
    SVProgressHUD.show()
  
    let connectioncheck = CheckNetworkConnect(host: Properties.ServerInfo["IPAddress"]!)
  
    if(!self.isConnectedFlg && !connectioncheck.isConnection()) {
      self.navigationItem.rightBarButtonItem?.enabled = false
      self.navigationItem.leftBarButtonItem?.enabled = false
      self.tableView.userInteractionEnabled = false
      
      let myAlert = UIAlertController(title: "ネットワークに\n接続されていません", message: "ネットワークに接続されていないため\nこのアプリを使用することはできません", preferredStyle: UIAlertControllerStyle.Alert)
      let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: { (action:UIAlertAction) -> Void in
        
      })
      
      myAlert.addAction(OKAction)
      
      self.view.window?.rootViewController?.presentViewController(myAlert, animated: true, completion: nil)
    
    }else{
      self.isConnectedFlg = true
    }

    
    SVProgressHUD.dismiss()
  }
  
  override func viewWillAppear(animated: Bool) {
    
    self.tableView.reloadData()
    
    deletePastData()
    
  }
  
  override func setEditing(editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    tableView.editing = editing
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidLayoutSubviews() {

  }
  
  override func numberOfSectionsInTableView(tableView:UITableView) -> Int{
    return 1
  }

  override func tableView(tableView:UITableView,numberOfRowsInSection section:Int) -> Int {
    return self.realm.objects(EmployeeData).filter(employeefilter).count
  }
  
  override func tableView(tableView:UITableView,cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("RegisteredCell",forIndexPath:indexPath) as UITableViewCell
    
    let employee = self.realm.objects(EmployeeData).filter(employeefilter)[indexPath.row]
    
    for subview in cell.contentView.subviews{
      switch subview.tag{
        case 1:
          let label = subview as? UILabel
          label?.text = employee.FamilyName + "　" + employee.FirstName
          
          break
      case 2:
        if(employee.LastUploadDate.characters.count != 0){
          let imageview = (subview as? UIImageView)!
          imageview.image = UIImage(named:"checkmark.png")
        }
        default:
          break
      }
    }
    
    return cell
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 60
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    var view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("Header")
    if view == nil {
      view = UITableViewHeaderFooterView(reuseIdentifier: "Header") as UITableViewHeaderFooterView
    }
    
    view?.textLabel?.text = "※このアプリで登録した従業員のみが表示されます\n※初回登録から1ヶ月経過した登録者は削除されます"
    return view
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    
    SVProgressHUD.show()
    
    //データ削除
    let employee = self.realm.objects(EmployeeData).filter(employeefilter)[indexPath.row]
    let delemployeecode = employee.EmployeeCode
    
    /* データ送信する前に削除した場合、同一の従業員番号はSQLServerのT_Employeeテーブル中に１つしかない。
      その場合はこの従業員番号は使用可能と判定する。
    */
    if(employee.LastUploadDate.isEmpty){
      //SQLServerの更新
      let client = SQLClient()
      let info = self.Properties.ServerInfo
      
      client.connect(info["IPAddress"], username: info["UserName"], password: info["Password"],
        database: info["DataBaseName"]) { (success:Bool) -> Void in
          if(success){
            let selsql = "select * from T_Employee where EmployeeCode = '\(delemployeecode)' and " +
            "FamilyName = '\(employee.FamilyName)' and FirstName = '\(employee.FirstName)' and DelFlg = 0"
#if DEBUG
  print("selsql = \(selsql)")
#endif
            
            client.execute(selsql, completion: { (results:[AnyObject]!) -> Void in
              
              if(results[0].count == 1){

                var updatesql = "update T_EmployeeAffliationRelation set AlreadyUsedFlg = 0 where EmployeeCode = '\(delemployeecode)';"
                updatesql = updatesql + "update T_Employee set DelFlg = 1 where EmployeeCode = '\(delemployeecode)' and SeqNo = '\(employee.SQLServerSeqNo)';"
#if DEBUG
  print("updatesql = \(updatesql)")
#endif
                
                
                client.execute(updatesql, completion: { (results:[AnyObject]!) -> Void in
                  
                  client.disconnect()
                  
                  try! self.realm.write({ () -> Void in
                    self.realm.delete(employee)
                    
                    let families = self.realm.objects(EmployeeData).filter("EmployeeCode='\(delemployeecode)'")
                    self.realm.delete(families)
                    
                    self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                  })
                  
                  
                  SVProgressHUD.dismiss()
                })
              }else{
                client.disconnect()
                
                try! self.realm.write({ () -> Void in
                  self.realm.delete(employee)
                  
                  let families = self.realm.objects(EmployeeData).filter("EmployeeCode='\(delemployeecode)'")
                  self.realm.delete(families)
                  
                  self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                })
              
                SVProgressHUD.dismiss()
            }
          })
        }
      }
    }else{
      try! self.realm.write({ () -> Void in
        self.realm.delete(employee)
        
        let families = self.realm.objects(EmployeeData).filter("EmployeeCode='\(delemployeecode)'")
        self.realm.delete(families)
        
        self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
      })
      
      SVProgressHUD.dismiss()
    }
  }
  
  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    
    return indexPath
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
  
  }
  
  
  @IBAction func tapAddNewButton(sender: UIBarButtonItem) {
  
    performSegueWithIdentifier("showAddNewEmployee", sender: self)
  }
  
  // MARK: - Segues
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showRegisterEdit" {
      let employeedata = self.realm.objects(EmployeeData).filter(self.employeefilter)[(self.tableView.indexPathForSelectedRow?.row)!]
     
      let regedit = segue.destinationViewController as? EditEmployeeViewController
      regedit?.EmployeeEditData = employeedata
    }
  }
  
  internal func changeTextField(sender:NSNotification){
    
    let textField = sender.object as! UITextField
    
    print(textField.text)
  }
  
  // MARK: 過去データの自動削除
  func deletePastData(){
    
    let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    
    let amonthago = calendar.dateByAddingUnit(NSCalendarUnit.Month, value: (-1) * (Properties.DeleteMonthSpan), toDate: NSDate(), options:NSCalendarOptions.MatchFirst)!
    
    print(amonthago)
    
    let dateformatter = NSDateFormatter()
    dateformatter.dateFormat = "yyyyMMddHHmmss"
    
    
    let alllist = realm.objects(EmployeeData)
    var dellist:[EmployeeData] = [EmployeeData]()
    
    for rec in alllist{
      if(Int(dateformatter.stringFromDate(rec.CreateDateTime)) < Int(dateformatter.stringFromDate(amonthago))){
        print("\(rec.EmployeeCode) \(rec.CreateDateTime)")
        dellist.append(rec)
      }
    }
    
    try! realm.write({ () -> Void in
      realm.delete(dellist)
    })
  }
  
  func tapVersionInfo(sender:UIBarButtonItem){
    let version:AnyObject! = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")
    let myAlert = UIAlertController(title: "MN登録\nVer.\(version)", message: "YUKO BEX Inc. All Rights Reserved.", preferredStyle: UIAlertControllerStyle.ActionSheet)
    let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler:nil)
    
    myAlert.addAction(OKAction)
    presentViewController(myAlert, animated: true, completion: nil)
  }
}

