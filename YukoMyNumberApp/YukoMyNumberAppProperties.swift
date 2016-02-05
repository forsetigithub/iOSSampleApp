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
      var PlistFileName:String?
      
#if DEBUG
  PlistFileName = "YukoMyNumberAppTest"
#else
  PlistFileName = "YukoMyNumberApp"
#endif
      let prop = NSBundle.mainBundle().pathForResource(PlistFileName, ofType: "plist")
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
  let ButtonTitles:[String:String] = dict.objectForKey("ButtonTitles") as! [String:String]
  let DateFormatStringJapanese:String = dict.objectForKey("DateFormatStringJapanese") as! String
  let JoinedDateLabelTapComment:String = dict.objectForKey("JoinedDateLabelTapComment") as! String
  let DateFormatStringSeparetedJapanese:String = dict.objectForKey("DateFormatStringSeparetedJapanese") as! String
  let AlertMessages:[String:AnyObject] = dict.objectForKey("AlertMessages") as! [String:AnyObject]
  let LocaleIdentifier:String = dict.objectForKey("LocaleIdentifier") as! String
  let SectionItems:[String:AnyObject] = dict.objectForKey("SectionItems") as! [String:AnyObject]
  let DeleteMonthSpan:Int = dict.objectForKey("DeleteMonthSpan") as! Int
  let ToolBarFixedSpaceSize:CGFloat = dict.objectForKey("ToolBarFixedSpaceSize") as! CGFloat
}
