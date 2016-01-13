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

class ModifyRelationViewController : UITableViewController,UIPickerViewDelegate,
  UIPickerViewDataSource{
  
  let realm = try! Realm()
  
  var FamilyItemData:EmployeeFamilyData = EmployeeFamilyData()
  
  @IBOutlet weak var RelationName: UILabel!
  @IBOutlet weak var RelationNamesPickerView: UIPickerView!
  
  
  let pickerItems:[String:String] = YukoMyNumberAppProperties.sharedInstance.RelationItems
  var pickerKeys:[String] = [String]()
  var pickerValues:[String] = [String]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "続柄"
    
    self.RelationNamesPickerView.delegate = self
    
    pickerKeys = Array(pickerItems.values).sort()
    
    for pikcerkey in pickerKeys {
      for (key,val) in pickerItems{
        if(pikcerkey == val){
          pickerValues.append(key)
        }
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    self.RelationName.text = FamilyItemData.RSName
    
  
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    try! realm.write({ () -> Void in
      
      self.FamilyItemData.RSName = self.RelationName.text!
      self.FamilyItemData.RSCode = YukoMyNumberAppProperties.sharedInstance.RelationItems[self.FamilyItemData.RSName]!
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
  
  //MARK: UIPickerView
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerItems.count
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    
    return pickerValues[row] as String
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
    if(row != 0){
      self.RelationName.text = pickerValues[row]
    }
  }

}
