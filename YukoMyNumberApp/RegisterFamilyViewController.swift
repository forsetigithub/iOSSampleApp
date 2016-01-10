//
//  RegisterFamilyViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/09.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation

class RegisterFamilyViewController : UITableViewController,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
  // MARK: - Table View
  
  @IBOutlet weak var RelationNamesPickerView: UIPickerView!

  @IBOutlet weak var RelationName: UILabel!
  
  private let pickerItems = ["続柄を選択","妻","子","父","母","祖母"]
  private var rowOpenFlag = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    self.RelationNamesPickerView.delegate = self
    self.RelationName.text = "続柄"
    
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {

  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    var height:CGFloat = 44
    if(indexPath.row == 3){
      height =  150
    }
    
    return height
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

  }
  
  //MARK: UIPickerView
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerItems.count
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerItems[row] as String
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    print("row: \(row)")
    print("value:\(pickerItems[row])")
    
    if(row != 0){
      self.RelationName.text = pickerItems[row]
    }
    
  }
  
}