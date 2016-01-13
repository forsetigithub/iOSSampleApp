//
//  EmployeeDataClass.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/06.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import RealmSwift

/*********************************************
** 従業員情報を保存する形式を定義するクラス(Realm) **
**********************************************/
class EmployeeData : Object {
  dynamic var EmployeeCode = ""
  dynamic var EmployeeFamilyName = ""
  dynamic var EmployeeFirstName = ""
  dynamic var EmployeeRSCode = "00"
  dynamic var EmployeeMN = ""
  dynamic var CreateDateTime = NSDate()
  dynamic var ReserveItem1 = ""
  dynamic var ReserveItem2 = ""
  dynamic var ReserveItem3 = ""
  dynamic var ReserveItem4 = ""
  dynamic var ReserveItem5 = ""
  dynamic var ReserveItem6 = ""
  dynamic var ReserveItem7 = ""
  dynamic var ReserveItem8 = ""
  dynamic var ReserveItem9 = ""
  dynamic var ReserveItem10 = ""
  
  
  let families = List<EmployeeFamilyData>()
}

class EmployeeFamilyData : Object {
  dynamic var FamilyName = ""
  dynamic var FirstName = ""
  dynamic var RSName = ""
  dynamic var RSCode = ""
  dynamic var FamilyMN = ""
  dynamic var DeleteFlag = false
  dynamic var ReserveItem1 = ""
  dynamic var ReserveItem2 = ""
  dynamic var ReserveItem3 = ""
  dynamic var ReserveItem4 = ""
  dynamic var ReserveItem5 = ""
  dynamic var ReserveItem6 = ""
  dynamic var ReserveItem7 = ""
  dynamic var ReserveItem8 = ""
  dynamic var ReserveItem9 = ""
  dynamic var ReserveItem10 = ""

}
