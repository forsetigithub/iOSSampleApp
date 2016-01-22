//
//  RelationPickerViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/19.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import UIKit

class RelationPickerViewController:NSObject,UIPickerViewDelegate,UIPickerViewDataSource{
  
  var RelationPickerView:UIPickerView?

  private let pickerItems:[String:String] = YukoMyNumberAppProperties.sharedInstance.RelationItems
  
  var pickerKeys:[String] = [String]()
  var pickerValues:[String] = [String]()
  
  var selectedPickerRow:Int = 0
  
  private var selectedrscode:String?
  var selectedRSCode:String{
    set{
      selectedrscode = newValue
      selectedRSName = pickerItems[selectedrscode!]
    }
    get{
      return selectedrscode!
    }
  }
  
  var selectedRSName:String?

  override init(){
    super.init()
    RelationPickerView = UIPickerView()
    pickerKeys = Array(pickerItems.keys).sort()
    
    for pikcerkey in pickerKeys {
      for (key,val) in pickerItems{
        if(pikcerkey == key){
          pickerValues.append(val)
        }
      }
    }
    
    RelationPickerView?.delegate = self
    
  }

  //MARK: UIPickerView
  @objc func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
    
    let pickerLabel = UILabel()
    pickerLabel.font = UIFont(name:"", size:YukoMyNumberAppProperties.sharedInstance.PickerLabelFontSize)

print("size:YukoMyNumberAppProperties.sharedInstance.PickerLabelFontSize = \(YukoMyNumberAppProperties.sharedInstance.PickerLabelFontSize ) pickerLabel.font=\(pickerLabel.font)")
    
    pickerLabel.text = pickerValues[row]
    pickerLabel.textAlignment = NSTextAlignment.Center
    
    return pickerLabel
  }
  
  @objc func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerItems.count
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    
    return pickerValues[row] as String
  }
 
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
    if(row != 0){
      selectedPickerRow = row
      selectedRSCode = pickerKeys[row]
      
      NSNotificationCenter.defaultCenter().postNotificationName("updatePickerNotification", object: nil)
    }
  }
}