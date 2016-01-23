//
//  ChangePassCodeViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/23.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import UIKit

class ChangePassCodeViewController:UITableViewController{

  override func viewDidLoad() {
    super.viewDidLoad()
   
    self.navigationItem.title = "暗証番号を変更"
    let saveButtonItem = UIBarButtonItem(title: "変更", style: UIBarButtonItemStyle.Done, target: self, action: "tapSavePassCodeButton:")
    self.navigationItem.rightBarButtonItem = saveButtonItem
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func tapSavePassCodeButton(sender:UIBarButtonItem){
    print("ChangePassCode")
    
   self.navigationController?.popViewControllerAnimated(true)
  }
  

}


