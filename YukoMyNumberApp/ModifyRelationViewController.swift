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
  
  fileprivate let RelationPicker = RelationPickerViewController()
  fileprivate var defaultRSCode:String{
    get{
      return self.FamilyItemData.RSCode
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = Properties.LabelItems["Relation"]

    self.RelationNamesPickerView.delegate = RelationPicker
    
    NotificationCenter.default.addObserver(self, selector: #selector(ModifyRelationViewController.updatePickerValue(_:)), name: NSNotification.Name(rawValue: "updatePickerNotification"), object: nil)
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    self.RelationName.text = FamilyItemData.RSName
    self.RelationPicker.selectedRSCode = FamilyItemData.RSCode
    
    let row = RelationPicker.pickerKeys.index(of: RelationPicker.selectedRSCode)
    self.RelationNamesPickerView!.selectRow(row!, inComponent: 0, animated: true)
    
    self.navigationController?.isToolbarHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
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
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    var height:CGFloat = Properties.TableViewCellDefaultHeight
    if(indexPath.row == 1){
      height = 150
    }
    
    return height
  }
  
  @objc func updatePickerValue(_ notification:Foundation.Notification){
    if((notification.name as AnyObject) as! String == "updatePickerNotification"){
      if(self.RelationPicker.selectedRSCode != defaultRSCode){
        if(realm.objects(EmployeeData.self).filter("EmployeeCode = '\(FamilyItemData.EmployeeCode)' and RSCode = '\(self.RelationPicker.selectedRSCode)'").count == 0){
          
          self.RelationName.text = self.RelationPicker.selectedRSName
          
        }else{
          let doubleerror:[String:String] = Properties.AlertMessages["DoubleCheckError"] as! [String:String]
          let myAlert = UIAlertController(title: doubleerror["Title"], message:"「\(self.RelationPicker.selectedRSName!)」は\(doubleerror["Message"]!)", preferredStyle: UIAlertController.Style.alert)
          let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: nil)
          
          myAlert.addAction(OKAction)
          present(myAlert, animated: true, completion: nil)
          
          self.RelationPicker.selectedRSCode = FamilyItemData.RSCode
        }
      }
    }
  }

}
