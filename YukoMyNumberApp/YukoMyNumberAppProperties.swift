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
  
  
  let MyNumberCharactersCount:NSNumber = (dict.objectForKey("MyNumberCharactersCount") as? NSNumber)!
  let EmployeeCodeLabelName = dict.objectForKey("EmployeeCodeLabelName")
  let EmployeeNameLabelName = dict.objectForKey("EmployeeNameLabelName")
  let EmployeeMNLabelName = dict.objectForKey("EmployeeMNLabelName")
  let RelationItems:[String:String] = dict.objectForKey("RelationItems") as! [String:String]
  let TableViewCellDefaultHeight:CGFloat = (dict.objectForKey("TableViewCellDefaultHeight") as? CGFloat)!
}

final class TestPropList {
  static let sharedInstance = TestPropList()
  
  private init(){}
  
  static private var dict : NSDictionary {
    get{
      let prop = NSBundle.mainBundle().pathForResource("TestPropList", ofType: "plist")
      return NSDictionary(contentsOfFile: prop!)!
    }
  }
  
  let TestMyNumber = dict.objectForKey("TestMyNumber")
}
