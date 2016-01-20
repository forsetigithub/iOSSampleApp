//
//  DatePickerViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/20.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import UIKit

class DatePickerViewController:UITableViewController{

  var DefaultDate:NSDate?
  var sourceViewController:RegisterEmployeeViewController?
  
  @IBOutlet weak var myDatePicker: UIDatePicker!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = "入社年月日"
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let regemp = sourceViewController{
      if let ddate:NSDate = regemp.JoinedDate {
        self.myDatePicker.date = ddate
      }
    }

  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)

    if let regemp = sourceViewController{
      regemp.JoinedDate = self.myDatePicker.date
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 200
  }

}
