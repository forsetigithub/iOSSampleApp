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
  dynamic var EmployeeName = ""
  dynamic var EmployeeRSCode = "00"
  dynamic var EmployeeMN = ""
  dynamic var CreateDateTime = NSDate()
  let families = List<EmployeeFamilyData>()
}

class EmployeeFamilyData : Object {
  dynamic var Name = ""
  dynamic var RSCode = ""
  dynamic var FamilyMN = ""

}
