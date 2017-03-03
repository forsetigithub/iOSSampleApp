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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}



class RegisteredListViewController: UITableViewController {
  
  let realm = try! Realm()
  
  fileprivate let Properties = YukoMyNumberAppProperties.sharedInstance
  fileprivate let employeefilter = NSPredicate(format: "RSCode = '00'")
  
  fileprivate var isConnectedFlg:Bool = false
  
  // MARK: - Table View
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = Properties.NavigationTitles["RegisteredListViewController"]
    self.navigationItem.leftBarButtonItem = editButtonItem
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Properties.ButtonTitles["AddNew"], style: UIBarButtonItemStyle.plain, target: self, action: #selector(RegisteredListViewController.tapAddNewButton(_:)))
    
    let infobutton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(RegisteredListViewController.tapVersionInfo(_:)))
    
    let barspace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
    barspace.width = self.view.bounds.size.width / 2 - Properties.ToolBarFixedSpaceSize
    self.toolbarItems = [barspace,infobutton]
    self.navigationController?.isToolbarHidden = false
  }

  override func viewWillLayoutSubviews() {

  }
  
  override func viewDidAppear(_ animated: Bool) {
  
    SVProgressHUD.show()
  
    let connectioncheck = CheckNetworkConnect(host: Properties.ServerInfo["IPAddress"]!)
  
    if(!self.isConnectedFlg && !connectioncheck.isConnection()) {
      self.navigationItem.rightBarButtonItem?.isEnabled = false
      self.navigationItem.leftBarButtonItem?.isEnabled = false
      self.tableView.isUserInteractionEnabled = false
      
      let myAlert = UIAlertController(title: "ネットワークに\n接続されていません", message: "ネットワークに接続されていないため\nこのアプリを使用することはできません", preferredStyle: UIAlertControllerStyle.alert)
      let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { (action:UIAlertAction) -> Void in
        
      })
      
      myAlert.addAction(OKAction)
      
      self.view.window?.rootViewController?.present(myAlert, animated: true, completion: nil)
    
    }else{
      self.isConnectedFlg = true
    }

    
    SVProgressHUD.dismiss()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    self.tableView.reloadData()
    
    deletePastData()
    
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    tableView.isEditing = editing
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidLayoutSubviews() {

  }
  
  override func numberOfSections(in tableView:UITableView) -> Int{
    return 1
  }

  override func tableView(_ tableView:UITableView,numberOfRowsInSection section:Int) -> Int {
    return self.realm.objects(EmployeeData.self).filter(employeefilter).count
  }
  
  override func tableView(_ tableView:UITableView,cellForRowAt indexPath:IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "RegisteredCell",for:indexPath) as UITableViewCell
    
    let employee = self.realm.objects(EmployeeData.self).filter(employeefilter)[indexPath.row]
    
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
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 60
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header")
    if view == nil {
      view = UITableViewHeaderFooterView(reuseIdentifier: "Header") as UITableViewHeaderFooterView
    }
    
    view?.textLabel?.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
    view?.textLabel?.numberOfLines = 2
    view?.textLabel?.text = "※このアプリで登録した従業員のみが表示されます\n※初回登録から1ヶ月経過した登録者は削除されます"
    return view
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
    SVProgressHUD.show()
    
    //データ削除
    let employee = self.realm.objects(EmployeeData.self).filter(employeefilter)[indexPath.row]
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
            
            client.execute(selsql, completion: { (results:[Any]?) -> Void in
              
              if((results?[0] as AnyObject).count == 1){

                var updatesql = "update T_EmployeeAffliationRelation set AlreadyUsedFlg = 0 where EmployeeCode = '\(delemployeecode)';"
                updatesql = updatesql + "update T_Employee set DelFlg = 1 where EmployeeCode = '\(delemployeecode)' and SeqNo = '\(employee.SQLServerSeqNo)';"
#if DEBUG
  print("updatesql = \(updatesql)")
#endif
                
                
                client.execute(updatesql, completion: { (results:[Any]?) -> Void in
                  
                  client.disconnect()
                  
                  try! self.realm.write({ () -> Void in
                    self.realm.delete(employee)
                    
                    let families = self.realm.objects(EmployeeData.self).filter("EmployeeCode='\(delemployeecode)'")
                    self.realm.delete(families)
                    
                    self.tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: UITableViewRowAnimation.fade)
                  })
                  
                  
                  SVProgressHUD.dismiss()
                })
              }else{
                client.disconnect()
                
                try! self.realm.write({ () -> Void in
                  self.realm.delete(employee)
                  
                  let families = self.realm.objects(EmployeeData.self).filter("EmployeeCode='\(delemployeecode)'")
                  self.realm.delete(families)
                  
                  self.tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: UITableViewRowAnimation.fade)
                })
              
                SVProgressHUD.dismiss()
            }
          })
        }
      }
    }else{
      try! self.realm.write({ () -> Void in
        self.realm.delete(employee)
        
        let families = self.realm.objects(EmployeeData.self).filter("EmployeeCode='\(delemployeecode)'")
        self.realm.delete(families)
        
        self.tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: UITableViewRowAnimation.fade)
      })
      
      SVProgressHUD.dismiss()
    }
  }
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    
    return indexPath
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  
  }
  
  
  @IBAction func tapAddNewButton(_ sender: UIBarButtonItem) {
  
    performSegue(withIdentifier: "showAddNewEmployee", sender: self)
  }
  
  // MARK: - Segues
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showRegisterEdit" {
      let employeedata = self.realm.objects(EmployeeData.self).filter(self.employeefilter)[(self.tableView.indexPathForSelectedRow?.row)!]
     
      let regedit = segue.destination as? EditEmployeeViewController
      regedit?.EmployeeEditData = employeedata
    }
  }
  
  internal func changeTextField(_ sender:Foundation.Notification){
    
    let textField = sender.object as! UITextField
    
    print(textField.text ?? " ")
  }
  
  // MARK: 過去データの自動削除
  func deletePastData(){
    
    let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    
    let amonthago = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.month, value: (-1) * (Properties.DeleteMonthSpan), to: Date(), options:NSCalendar.Options.matchFirst)!
    
    print(amonthago)
    
    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "yyyyMMddHHmmss"
    
    
    let alllist = realm.objects(EmployeeData.self)
    var dellist:[EmployeeData] = [EmployeeData]()
    
    for rec in alllist{
      if(Int(dateformatter.string(from: rec.CreateDateTime)) < Int(dateformatter.string(from: amonthago))){
        print("\(rec.EmployeeCode) \(rec.CreateDateTime)")
        dellist.append(rec)
      }
    }
    
    try! realm.write({ () -> Void in
      realm.delete(dellist)
    })
  }
  
  func tapVersionInfo(_ sender:UIBarButtonItem){
    let version:String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let myAlert = UIAlertController(title: "MN登録\nVer.\(version)", message: "YUKO BEX Inc. All Rights Reserved.", preferredStyle: UIAlertControllerStyle.actionSheet)
    let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:nil)
    
    myAlert.addAction(OKAction)
    present(myAlert, animated: true, completion: nil)
  }
}

