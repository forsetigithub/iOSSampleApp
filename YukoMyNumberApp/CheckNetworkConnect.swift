//
//  CheckNetworkConnect.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/29.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation

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
  /*
  private(set) var checkResult = false{
    didSet{
      if(checkResult){
        NSNotificationCenter.defaultCenter().postNotificationName(PingSucessNotification, object: self)
      }
    }
  }
*/
  private var pingTimer: NSTimer?
  private var lastSequenceSent: UInt16?
  private var lastSentTime: NSDate?
  var lagTimes = [Double?]()
  private var lastLag: Double? {
    didSet {
      lagTimes.append(lastLag)
      if lagTimes.count > numberOfSamples {
        lagTimes.removeRange(0..<(lagTimes.count - numberOfSamples))
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
  private(set) var running = false {
    didSet {
      if running {
        NSNotificationCenter.defaultCenter().postNotificationName(PingStartedNotification, object: self)
      } else {
        NSNotificationCenter.defaultCenter().postNotificationName(PingStoppedNotification, object: self)
      }
    }
  }
  private(set) var status = Status.Unknown {
    didSet {
      NSNotificationCenter.defaultCenter().postNotificationName(StatusChangedNotification, object: self)
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
    
  }
  func sendPing() {
    if let pinger = simplePing {
      print("ping to \(host) checkCounter = \(checkCounter) canStartPinging = \(canStartPinging)");
      pinger.sendPingWithData(nil)
    }
  }
}
extension CheckNetworkConnect: SimplePingDelegate {
  func simplePing(pinger: SimplePing!, didStartWithAddress address: NSData!) {
    print("did start")
    self.sendPing()
    self.canStartPinging = true
    status = Status.Unknown
    pingTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("sendPing"), userInfo: nil, repeats: true)
  }
  func simplePing(pinger: SimplePing!, didFailWithError error: NSError!) {
    status = Status.Failure
    print("failed with error: \(error)")
  }
  func simplePing(pinger: SimplePing!, didSendPacket packet: NSData!, withSequenceNumber sequenceNumber:UInt16) {
    let seqNo = CFSwapInt16BigToHost(sequenceNumber)
    lastSequenceSent = seqNo
    lastSentTime = NSDate()
  }
  func simplePing(pinger: SimplePing!, didFailToSendPacket packet: NSData!, error: NSError!) {
    status = Status.Error
    print("failed to send packet")
  }
  func simplePing(pinger: SimplePing!, didReceivePingResponsePacket packet: NSData!) {
    status = Status.Success
    let seqNo = CFSwapInt16BigToHost(SimplePing.icmpInPacket(packet).memory.sequenceNumber)
    if seqNo < lastSequenceSent {
      print("out of order")
    } else {
      if let lastTime = lastSentTime {
        lastLag = NSDate().timeIntervalSinceDate(lastTime) * 1_000
        print("pong \(seqNo) - lag \(lastLag)")
        print("running average: \(averageLag)")
      }
    }
  }
  func simplePing(pinger: SimplePing!, didReceiveUnexpectedPacket packet: NSData!) {
    //        println("received unexpected packet")
    
  }
  
  func isConnection()-> Bool{
    var checkResult = false
    
    self.start()
   
    repeat{
      
      if(canStartPinging){

        print("status = \(self.status) checkcounter = \(self.checkCounter) checkResult = \(checkResult)")
        
        if(self.status == Status.Success){
          checkResult = true
          self.stop()
        }else{
          self.checkCounter++
        }
        
        if(self.checkCounter > YukoMyNumberAppProperties.sharedInstance.PingCheckCounter){
          self.stop()
        }
      }

      NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture())
    }while(self.running)

    return checkResult
  }

}

