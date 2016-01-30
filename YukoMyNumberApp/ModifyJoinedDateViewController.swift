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
  
  private var tapJoinedDateLabelFlag:Bool = false
  private var formatter:NSDateFormatter = NSDateFormatter()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = YukoMyNumberAppProperties.sharedInstance.LabelItems["EmployeeJoinedDate"]
    
    self.joinedDateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapJoinedDateLabel:"))
    
    self.formatter.dateFormat = YukoMyNumberAppProperties.sharedInstance.DateFormatStringJapanese
  }
  
  override func viewWillAppear(animated: Bool) {
    self.myDatePicker.date = EmployeeEditData!.JoinedDate

    self.joinedDateLabel.text = formatter.stringFromDate((self.EmployeeEditData?.JoinedDate)!)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    try! realm.write({ () -> Void in
      EmployeeEditData!.JoinedDate = self.myDatePicker.date
    })
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
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
  
  func tapJoinedDateLabel(sender:UILabel){
    
    self.tapJoinedDateLabelFlag = !(self.tapJoinedDateLabelFlag)
    
    if(self.tapJoinedDateLabelFlag){
      self.joinedDateLabel.textColor = UIColor.blueColor()
    }else{
      self.joinedDateLabel.textColor = UIColor.blackColor()
    }
    
    self.tableView.reloadData()
  }
  
  @IBAction func changeDatePicker(sender: UIDatePicker) {
    self.joinedDateLabel.text =  self.formatter.stringFromDate(sender.date)
    
    self.tableView.reloadData()
  
  }
  

}
