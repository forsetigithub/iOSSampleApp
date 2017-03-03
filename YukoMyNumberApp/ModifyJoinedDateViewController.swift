//
//  DatePickerViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/20.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ModifyJoinedDateViewController:UITableViewController{

  var EmployeeEditData:EmployeeData?

  let realm = try! Realm()
  
  @IBOutlet weak var myDatePicker: UIDatePicker!
  @IBOutlet weak var joinedDateLabel: UILabel!
  
  fileprivate var tapJoinedDateLabelFlag:Bool = false
  fileprivate var formatter:DateFormatter = DateFormatter()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = YukoMyNumberAppProperties.sharedInstance.LabelItems["EmployeeJoinedDate"]
    
    self.joinedDateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ModifyJoinedDateViewController.tapJoinedDateLabel(_:))))
    
    self.formatter.dateFormat = YukoMyNumberAppProperties.sharedInstance.DateFormatStringJapanese
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.myDatePicker.date = EmployeeEditData!.JoinedDate as Date

    self.joinedDateLabel.text = formatter.string(from: (self.EmployeeEditData?.JoinedDate)! as Date)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    try! realm.write({ () -> Void in
      EmployeeEditData!.JoinedDate = self.myDatePicker.date
    })
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    var height = YukoMyNumberAppProperties.sharedInstance.TableViewCellDefaultHeight
    
    if(indexPath.section == 0 && indexPath.row == 1 ){
      if(tapJoinedDateLabelFlag){
        height = 200
      }else{
        height = 0
      }
    }
    
    return height
  }
  
  func tapJoinedDateLabel(_ sender:UILabel){
    
    self.tapJoinedDateLabelFlag = !(self.tapJoinedDateLabelFlag)
    
    if(self.tapJoinedDateLabelFlag){
      self.joinedDateLabel.textColor = UIColor.blue
    }else{
      self.joinedDateLabel.textColor = UIColor.black
    }
    
    self.tableView.reloadData()
  }
  
  @IBAction func changeDatePicker(_ sender: UIDatePicker) {
    self.joinedDateLabel.text =  self.formatter.string(from: sender.date)
    
    self.tableView.reloadData()
  
  }
  

}
