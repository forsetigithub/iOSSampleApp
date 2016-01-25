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
  
  var FamilyItemData:EmployeeData = EmployeeData()
  
  @IBOutlet weak var RelationName: UILabel!
  @IBOutlet weak var RelationNamesPickerView: UIPickerView!
  
  
  private let RelationPicker = RelationPickerViewController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "続柄"
    
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
    super.viewWillDisappear(animated)
    
    try! realm.write({ () -> Void in
      self.FamilyItemData.RSCode = self.RelationPicker.selectedRSCode
    })
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  //MARK: TableView
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    var height:CGFloat = YukoMyNumberAppProperties.sharedInstance.TableViewCellDefaultHeight
    if(indexPath.row == 1){
      height = 150
    }
    
    return height
  }
  
  func updatePickerValue(notification:NSNotification){
    if(notification.name == "updatePickerNotification"){
      self.RelationName.text = self.RelationPicker.selectedRSName
    }
  }

}
