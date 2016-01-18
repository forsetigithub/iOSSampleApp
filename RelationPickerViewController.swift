//
//  RelationPickerViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/19.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import UIKit

class RelationPickerViewController:NSObject,UIPickerViewDelegate{
  
  let RelationPickerView:UIPickerView
  var SelectedRelation:String
  
  private let pickerItems:[String:String] = YukoMyNumberAppProperties.sharedInstance.RelationItems
  
  private var pickerKeys:[String] = [String]()
  private var pickerValues:[String] = [String]()
  private var selectedPickerRow:Int = 0
  
  override init(){
    RelationPickerView = UIPickerView()
    SelectedRelation = ""
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
      SelectedRelation = pickerValues[row]
      selectedPickerRow = row
    }
  }

}