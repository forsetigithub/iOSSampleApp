//
//  YukoMyNumberAppProperties.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/08.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation

final class YukoMyNumberAppProperties {
  static let sharedInstance = YukoMyNumberAppProperties()
  
  private init(){}
  
  static private var dict:NSDictionary{
    get{
      let prop = NSBundle.mainBundle().pathForResource("YukoMyNumberApp", ofType: "plist")
      return NSDictionary(contentsOfFile: prop!)!
    }
  }
  
  let LabelItems:[String:String] = dict.objectForKey("LabelItems") as! [String:String]
  let MyNumberCharactersCount:Int = (dict.objectForKey("MyNumberCharactersCount") as? Int)!
  let EmployeeCodeCharactersCount:Int = (dict.objectForKey("EmployeeCodeCharactersCount") as? Int)!
  let EmployeeNameCharactersCount:Int = (dict.objectForKey("EmployeeNameCharactersCount") as? Int)!
  let RelationItems:[String:String] = dict.objectForKey("RelationItems") as! [String:String]
  let TableViewCellDefaultHeight:CGFloat = (dict.objectForKey("TableViewCellDefaultHeight") as? CGFloat)!
  let ServerInfo:[String:String] = dict.objectForKey("ServerInfo") as! [String:String]
  let ButtonInTableViewFontSize = (dict.objectForKey("ButtonInTableViewFontSize") as? CGFloat)!
  let AppDefaultFontSize = (dict.objectForKey("AppDefaultFontSize") as? CGFloat)!
  let PickerLabelFontSize = (dict.objectForKey("PickerLabelFontSize") as? CGFloat)!
  let PassCodeCharactersCount = (dict.objectForKey("PassCodeCharactersCount") as? Int)!
  let PingCheckCounter:Int = (dict.objectForKey("PingCheckCounter") as? Int)!
  let NavigationTitles:[String:String] = dict.objectForKey("NavigationTitles") as! [String:String]
  let ButtonTitleRegister:String = dict.objectForKey("ButtonTitleRegister") as! String
  let ButtonTitleModify:String = dict.objectForKey("ButtonTitleModify") as! String
  let DateFormatStringJapanese:String = dict.objectForKey("DateFormatStringJapanese") as! String
  
  
}
