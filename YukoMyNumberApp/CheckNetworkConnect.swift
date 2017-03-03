//
//  CheckNetworkConnect.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/29.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


let StatusChangedNotification = "status-changed-notification"
let PingStoppedNotification = "ping-stopped-notification"
let PingStartedNotification = "ping-started-notification"
let PingSucessNotification = "ping-sucess-notification"
enum Status: String {
  case Success = "OK"
  case Failure = "Failing"
  case Error = "Error"
  case Unknown = "Unknown"
  case NotRunning = "Not Running"
}
/* 
* ネットワーク状態を管理する
*/
class CheckNetworkConnect:NSObject{
  static let DefaultHost = "8.8.8.8"
  static let DefaultInterval = 2.0
  static let DefaultNumberOfSamples = 10
  var host: String
  var interval: Double
  var numberOfSamples: Int
  var simplePing: SimplePing?
  var canStartPinging = false
  var checkCounter = 0
  
  fileprivate var pingTimer: Timer?
  fileprivate var lastSequenceSent: UInt16?
  fileprivate var lastSentTime: Date?
  var lagTimes = [Double?]()
  fileprivate var lastLag: Double? {
    didSet {
      lagTimes.append(lastLag)
      if lagTimes.count > numberOfSamples {
        lagTimes.removeSubrange(0..<(lagTimes.count - numberOfSamples))
      }
    }
  }
  var averageLag: Double? {
    get {
      if !self.running {
        return nil
      }
      let filteredArray = lagTimes.filter { $0 != nil }
      if filteredArray.count == 0 {
        return nil
      }
      return Double(filteredArray.reduce(0.0) { $0 + $1! }) / Double(filteredArray.count)
    }
  }
  var dropOutRate: Double? {
    if !self.running {
      return nil
    }
    if lagTimes.count == 0 {
      return 0
    }
    let dropOuts = lagTimes.filter { $0 == nil }.count
    return Double(dropOuts) / Double(lagTimes.count)
  }
  fileprivate(set) var running = false {
    didSet {
      if running {
        NotificationCenter.default.post(name: Notification.Name(rawValue: PingStartedNotification), object: self)
      } else {
        NotificationCenter.default.post(name: Notification.Name(rawValue: PingStoppedNotification), object: self)
      }
    }
  }
  fileprivate(set) var status = Status.Unknown {
    didSet {
      NotificationCenter.default.post(name: Notification.Name(rawValue: StatusChangedNotification), object: self)
    }
  }
  init(host: String = DefaultHost, interval: Double = DefaultInterval, numberOfSamples: Int = DefaultNumberOfSamples) {
    self.host = host
    self.interval = interval
    self.numberOfSamples = numberOfSamples
  }
  func start() {
    if self.running {
      stop()
    }
    print("starting…")
    status = Status.Unknown
    simplePing = SimplePing(hostName: host)
    if let pinger = simplePing {
      pinger.delegate = self
      pinger.start()
      running = true
    } else {
      stop()
    }
  }
  func stop() {
    print("stopping…")
    if let pinger = simplePing {
      pinger.stop()
    }
    if let timer = pingTimer {
      timer.invalidate()
    }
    running = false
    status = Status.NotRunning
    canStartPinging = false
  }
  func sendPing() {
    if let pinger = simplePing {
      if(canStartPinging){
        print("ping to \(host) checkCounter = \(checkCounter) canStartPinging = \(canStartPinging)");
        pinger.send(with: nil)
      }
    }
  }
}
extension CheckNetworkConnect: SimplePingDelegate {
  func simplePing(_ pinger: SimplePing!, didStartWithAddress address: Data!) {
    print("did start")
    self.canStartPinging = true
    status = Status.Unknown
  }
  func simplePing(_ pinger: SimplePing!, didFailWithError error: Error!) {
    status = Status.Failure
    print("failed with error: \(error)")
  }
  func simplePing(_ pinger: SimplePing!, didSendPacket packet: Data!, withSequenceNumber sequenceNumber:UInt16) {
    let seqNo = CFSwapInt16BigToHost(sequenceNumber)
    lastSequenceSent = seqNo
    lastSentTime = Date()
  }
  func simplePing(_ pinger: SimplePing!, didFailToSendPacket packet: Data!, error: Error!) {
    status = Status.Error
    print("failed to send packet")
  }
  func simplePing(_ pinger: SimplePing!, didReceivePingResponsePacket packet: Data!) {
    status = Status.Success
    let seqNo = CFSwapInt16BigToHost(SimplePing.icmp(inPacket: packet).pointee.sequenceNumber)
    if seqNo < lastSequenceSent {
      print("out of order")
    } else {
      if let lastTime = lastSentTime {
        lastLag = Date().timeIntervalSince(lastTime) * 1_000
        print("pong \(seqNo) - lag \(lastLag)")
        print("running average: \(averageLag)")
      }
    }
  }
  func simplePing(_ pinger: SimplePing!, didReceiveUnexpectedPacket packet: Data!) {
    //        println("received unexpected packet")
    
  }
  
  func isConnection()-> Bool{
    var checkResult = false
    
    self.start()
   
    repeat{
      
      if(canStartPinging){

        print("status = \(self.status) checkcounter = \(self.checkCounter) checkResult = \(checkResult)")
        
        self.sendPing()
        
        if(self.status == Status.Success){
          checkResult = true
          self.stop()
        }else if(self.status == Status.Error){
          self.stop()
        }else {
          self.checkCounter += 1
          print("checkCounter=\(checkCounter)")
        }
        
        if(self.checkCounter > YukoMyNumberAppProperties.sharedInstance.PingCheckCounter){
          self.stop()
        }
      }

      RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
      
    }while(self.running)

    return checkResult
  }

}

