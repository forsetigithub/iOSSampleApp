//
//  CustomSegues.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/26.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import UIKit

/* 
* 上から下へ画面遷移する
*/
class TopToDownSegue:UIStoryboardSegue{
  override func perform() {
    let firstVCView = self.sourceViewController.view as UIView!
    let secondVCView = self.destinationViewController.view as UIView!
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    
    secondVCView.frame = CGRectMake(0.0, -screenHeight, screenWidth, screenHeight)
    
    // Access the app's key window and insert the destination view above the current (source) one.
    let window = UIApplication.sharedApplication().keyWindow
    window?.insertSubview(secondVCView, aboveSubview: firstVCView)
    
    // Animate the transition.
    UIView.animateWithDuration(0.45, animations: { () -> Void in
      firstVCView.frame = CGRectOffset(firstVCView.frame, 0.0, screenHeight)
      secondVCView.frame = CGRectOffset(secondVCView.frame, 0.0, screenHeight)
      }) { (finished) -> Void in
        self.sourceViewController.presentViewController(self.destinationViewController , animated: false, completion: nil)
    }
  }
}

