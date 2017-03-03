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
  
  fileprivate init(){}
  
  static fileprivate var dict:NSDictionary{
    get{
      var PlistFileName:String?
      
#if DEBUG
  PlistFileName = "YukoMyNumberAppTest"
#else
  PlistFileName = "YukoMyNumberApp"
#endif
      let prop = Bundle.main.path(forResource: PlistFileName, ofType: "plist")
      return NSDictionary(contentsOfFile: prop!)!
    }
  }
  
  let LabelItems:[String:String] = dict.object(forKey: "LabelItems") as! [String:String]
  let MyNumberCharactersCount:Int = (dict.object(forKey: "MyNumberCharactersCount") as? Int)!
  let EmployeeCodeCharactersCount:Int = (dict.object(forKey: "EmployeeCodeCharactersCount") as? Int)!
  let EmployeeNameCharactersCount:Int = (dict.object(forKey: "EmployeeNameCharactersCount") as? Int)!
  let RelationItems:[String:String] = dict.object(forKey: "RelationItems") as! [String:String]
  let TableViewCellDefaultHeight:CGFloat = (dict.object(forKey: "TableViewCellDefaultHeight") as? CGFloat)!
  let ServerInfo:[String:String] = dict.object(forKey: "ServerInfo") as! [String:String]
  let ButtonInTableViewFontSize = (dict.object(forKey: "ButtonInTableViewFontSize") as? CGFloat)!
  let AppDefaultFontSize = (dict.object(forKey: "AppDefaultFontSize") as? CGFloat)!
  let PickerLabelFontSize = (dict.object(forKey: "PickerLabelFontSize") as? CGFloat)!
  let PassCodeCharactersCount = (dict.object(forKey: "PassCodeCharactersCount") as? Int)!
  let PingCheckCounter:Int = (dict.object(forKey: "PingCheckCounter") as? Int)!
  let NavigationTitles:[String:String] = dict.object(forKey: "NavigationTitles") as! [String:String]
  let ButtonTitles:[String:String] = dict.object(forKey: "ButtonTitles") as! [String:String]
  let DateFormatStringJapanese:String = dict.object(forKey: "DateFormatStringJapanese") as! String
  let JoinedDateLabelTapComment:String = dict.object(forKey: "JoinedDateLabelTapComment") as! String
  let DateFormatStringSeparetedJapanese:String = dict.object(forKey: "DateFormatStringSeparetedJapanese") as! String
  let AlertMessages:[String:AnyObject] = dict.object(forKey: "AlertMessages") as! [String:AnyObject]
  let LocaleIdentifier:String = dict.object(forKey: "LocaleIdentifier") as! String
  let SectionItems:[String:AnyObject] = dict.object(forKey: "SectionItems") as! [String:AnyObject]
  let DeleteMonthSpan:Int = dict.object(forKey: "DeleteMonthSpan") as! Int
  let ToolBarFixedSpaceSize:CGFloat = dict.object(forKey: "ToolBarFixedSpaceSize") as! CGFloat
}
