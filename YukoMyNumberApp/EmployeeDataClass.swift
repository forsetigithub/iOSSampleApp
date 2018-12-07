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
  @objc dynamic var EmployeeCode = ""
  @objc dynamic var RecKindNo = 0
  @objc dynamic var FamilySeqNo = 0
  @objc dynamic var FamilyName = ""
  @objc dynamic var FirstName = ""
  @objc dynamic var RSCode = ""
  
  var RSName:String{
    return YukoMyNumberAppProperties.sharedInstance.RelationItems[self.RSCode]!
  }
  
  @objc dynamic var MyNumber = ""
  
  var MyNumberCheckDigitResult:Bool{
    if(!MyNumber.isEmpty){
      return self.MyNumber.isValidMyNumber()
    }else{
      return false
    }
  }
  
  @objc dynamic var CreateDateTime = Date()
  @objc dynamic var DeleteFlag = false
  @objc dynamic var PassCode = ""
  @objc dynamic var JoinedDate = Date()
  @objc dynamic var LastUploadDate = ""
  @objc dynamic var MNRegisterMode = 1 //マイナンバー登録モード(1:手動 2:OCR)
  @objc dynamic var SQLServerSeqNo = ""
  //予備エリア
  @objc dynamic var ReserveItem1 = ""
  @objc dynamic var ReserveItem2 = ""
  @objc dynamic var ReserveItem3 = ""
  @objc dynamic var ReserveItem4 = ""
  @objc dynamic var ReserveItem5 = ""
  @objc dynamic var ReserveItem6 = ""
  @objc dynamic var ReserveItem7 = ""
  @objc dynamic var ReserveItem8 = ""
  @objc dynamic var ReserveItem9 = ""
  @objc dynamic var ReserveItem10 = ""
  @objc dynamic var ReserveItem11 = ""
  @objc dynamic var ReserveItem12 = ""
  @objc dynamic var ReserveItem13 = ""
  @objc dynamic var ReserveItem14 = ""
  @objc dynamic var ReserveItem15 = ""
  @objc dynamic var ReserveItem16 = ""
  @objc dynamic var ReserveItem17 = ""
  @objc dynamic var ReserveItem18 = ""
  @objc dynamic var ReserveItem19 = ""
  @objc dynamic var ReserveItem20 = ""
  
}
