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
  
  var FamilyItemData:EmployeeData = EmployeeData()
  
  @IBOutlet weak var RelationName: UILabel!
  @IBOutlet weak var RelationNamesPickerView: UIPickerView!
  
  private let pickerItems:[String:String] = YukoMyNumberAppProperties.sharedInstance.RelationItems
  private var pickerKeys:[String] = [String]()
  private var pickerValues:[String] = [String]()
  private var selectedPickerRow:Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "続柄"
    
    self.RelationNamesPickerView.delegate = self
    
    pickerKeys = Array(pickerItems.keys).sort()
    
    for pikcerkey in pickerKeys {
      for (key,val) in pickerItems{
        if(pikcerkey == key){
          pickerValues.append(val)
        }
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    
    super.viewWillAppear(animated)
    
    self.RelationName.text = FamilyItemData.RSName
    
    selectedPickerRow = pickerKeys.indexOf(FamilyItemData.RSCode)!
    self.RelationNamesPickerView.selectRow(selectedPickerRow, inComponent: 0, animated: true)
  
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    try! realm.write({ () -> Void in
      self.FamilyItemData.RSCode = pickerKeys[selectedPickerRow]
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
  
  func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
    let pickerLabel = UILabel()
    pickerLabel.font = UIFont(name:"", size:YukoMyNumberAppProperties.sharedInstance.AppDefaultFontSize)
    pickerLabel.text = pickerValues[row]
    pickerLabel.textAlignment = NSTextAlignment.Center
    
    return pickerLabel
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
      self.selectedPickerRow = row
    }
  }

}
