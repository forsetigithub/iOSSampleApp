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
  dynamic var RecKindNo = 0
  dynamic var FamilySeqNo = 0
  dynamic var FamilyName = ""
  dynamic var FirstName = ""
  dynamic var RSCode = ""
  
  var RSName:String{
    return YukoMyNumberAppProperties.sharedInstance.RelationItems[self.RSCode]!
  }
  
  dynamic var MyNumber = ""
  
  var MyNumberCheckDigitResult:Bool{
    return self.MyNumber.isValidMyNumber()
  }
  
  dynamic var CreateDateTime = NSDate()
  dynamic var DeleteFlag = false
  dynamic var PassCode = ""
  dynamic var JoinedDate = NSDate()
  dynamic var LastUploadDate = ""
  dynamic var MNRegisterMode = 1 //マイナンバー登録モード(1:手動 2:OCR)
  //予備エリア
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
  dynamic var ReserveItem11 = ""
  dynamic var ReserveItem12 = ""
  dynamic var ReserveItem13 = ""
  dynamic var ReserveItem14 = ""
  dynamic var ReserveItem15 = ""
  dynamic var ReserveItem16 = ""
  dynamic var ReserveItem17 = ""
  dynamic var ReserveItem18 = ""
  dynamic var ReserveItem19 = ""
  dynamic var ReserveItem20 = ""
  
}
