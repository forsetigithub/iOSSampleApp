//
//  ModifyRelationViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/13.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ModifyRelationViewController : UITableViewController,UIPickerViewDelegate{
  
  let realm = try! Realm()
  let Properties = YukoMyNumberAppProperties.sharedInstance
  
  var FamilyItemData:EmployeeData = EmployeeData()
  
  @IBOutlet weak var RelationName: UILabel!
  @IBOutlet weak var RelationNamesPickerView: UIPickerView!
  
  private let RelationPicker = RelationPickerViewController()
  private var defaultRSCode:String{
    get{
      return self.FamilyItemData.RSCode
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = Properties.LabelItems["Relation"]

    self.RelationNamesPickerView.delegate = RelationPicker
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePickerValue:", name: "updatePickerNotification", object: nil)
    
  }
  
  override func viewWillAppear(animated: Bool) {
    
    self.RelationName.text = FamilyItemData.RSName
    self.RelationPicker.selectedRSCode = FamilyItemData.RSCode
    
    let row = RelationPicker.pickerKeys.indexOf(RelationPicker.selectedRSCode)
    self.RelationNamesPickerView!.selectRow(row!, inComponent: 0, animated: true)
    
    self.navigationController?.toolbarHidden = true
  }
  
  override func viewWillDisappear(animated: Bool) {
    if(self.RelationPicker.selectedRSCode != defaultRSCode){
      try! realm.write({ () -> Void in
        self.FamilyItemData.RSCode = self.RelationPicker.selectedRSCode
      })
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  //MARK: TableView
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    var height:CGFloat = Properties.TableViewCellDefaultHeight
    if(indexPath.row == 1){
      height = 150
    }
    
    return height
  }
  
  func updatePickerValue(notification:NSNotification){
    if(notification.name == "updatePickerNotification"){
      if(self.RelationPicker.selectedRSCode != defaultRSCode){
        if(realm.objects(EmployeeData).filter("EmployeeCode = '\(FamilyItemData.EmployeeCode)' and RSCode = '\(self.RelationPicker.selectedRSCode)'").count == 0){
          
          self.RelationName.text = self.RelationPicker.selectedRSName
          
        }else{
          let doubleerror:[String:String] = Properties.AlertMessages["DoubleCheckError"] as! [String:String]
          let myAlert = UIAlertController(title: doubleerror["Title"], message:"「\(self.RelationPicker.selectedRSName!)」は\(doubleerror["Message"]!)", preferredStyle: UIAlertControllerStyle.Alert)
          let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
          
          myAlert.addAction(OKAction)
          presentViewController(myAlert, animated: true, completion: nil)
          
          self.RelationPicker.selectedRSCode = FamilyItemData.RSCode
        }
      }
    }
  }

}
