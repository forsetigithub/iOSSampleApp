//
//  MyNumberCheckDigit.swift
//  MyNumberOCRDemo1
//
//  Created by 木村正徳 on 2015/11/06.
//  Copyright © 2015年 yukobex. All rights reserved.
//

import Foundation
extension String {
  func isValidMyNumber() -> Bool {
    let numbers = self.characters.flatMap { (character) -> Int? in
      return Int(String(character))
    }
    guard numbers.count == 12 else {
      return false
    }
    var sum = 0
    for index in 1 ... 11 {
      let p = numbers[11 - index]
      let q: Int
      if 1 ... 6 ~= index {
        q = index + 1
      } else {
        q = index - 5
      }
      sum += p * q
    }
    return 11 - sum % 11 == numbers[11]
  }
}