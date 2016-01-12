//
//  ViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/05.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import UIKit
import RealmSwift

class RegisteredListViewController: UITableViewController {

  
  let realm = try! Realm()
  
  // MARK: - Segues
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showRegisterEdit" {
      let regedit = segue.destinationViewController as? EditEmployeeViewController
      regedit?.EmployeeEditData = self.realm.objects(EmployeeData)[(self.tableView.indexPathForSelectedRow?.row)!]
    }
  }
  
  // MARK: - Table View
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = editButtonItem()
  }
  
  override func setEditing(editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    tableView.editing = editing
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func numberOfSectionsInTableView(tableView:UITableView) -> Int{
    return 1
  }

  override func tableView(tableView:UITableView,numberOfRowsInSection section:Int) -> Int {
    return self.realm.objects(EmployeeData).count
  }
  
  override func tableView(tableView:UITableView,cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("RegisteredCell",forIndexPath:indexPath) as UITableViewCell
    let employee = self.realm.objects(EmployeeData)[indexPath.row]
    cell.textLabel!.text = employee.EmployeeFamilyName + "　" + employee.EmployeeFirstName
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
    
    view?.textLabel?.text = "※このアプリで登録した社員のみが表示されます\n※初回登録から1ヶ月経過した登録者は削除されます"
    return view
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
   let delitem = self.realm.objects(EmployeeData)[indexPath.row]
    
    try! realm.write({ () -> Void in
      realm.delete(delitem)
    })
    
    
    tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
  }
  
  @IBAction func tapAddNewButton(sender: UIBarButtonItem) {
  
    performSegueWithIdentifier("showAddNewEmployee", sender: self)
  }
}

