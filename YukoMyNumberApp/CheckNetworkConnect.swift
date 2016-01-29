//
//  CheckNetworkConnect.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/29.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import SystemConfiguration

/* 
* ネットワーク状態を管理する
*/
class CheckNetworkConnect{
  
  /* 
  * host_nameに接続しているかを確認する
  */
  func CheckNetworkConnection(host_name:String) -> Bool{
    let connection = SCNetworkReachabilityCreateWithName(nil, host_name)
    var flags = SCNetworkReachabilityFlags.ConnectionAutomatic
    if(!SCNetworkReachabilityGetFlags(connection!, &flags)){
      return false
    }
    
    let isConnected = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired) != 0)
    return (isConnected && !needsConnection)
    
  }

}
