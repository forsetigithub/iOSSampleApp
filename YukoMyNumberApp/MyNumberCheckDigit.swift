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
    // 桁数チェック
    let numbers = self.replacingOccurrences(of: " ", with: "")
    let length = numbers.utf8.count
    if length != 12 {
      return false
    }
    
    // 正規表現を使って数字のみかどうかチェック
    let exp = try! NSRegularExpression(pattern: "^[0-9]+$", options: [])
    if exp.matches(in: numbers, options: [], range: NSMakeRange(0, length)).count == 0 {
      return false
    }
    
    // 扱いやすいように一旦Stringを１文字ずつ分割
    var characters = numbers.characters.map{ String($0) }
    // チェックデジットをcharactersからpop
    // pop後はcharactersの中身は12->11個になります。
    let checkDigit = Int(characters.removeLast())!
    
    // 検査用数字の計算
    var pq = 0
    
    for (index, num) in characters.reversed().enumerated() {
      let n = index + 1
      let p = Int(num)!
      let q = (n >= 7) ? n - 5 : n + 1
      pq += p * q
    }
    
    // 検査
    let remainder = pq % 11
    return (remainder <= 1) ? (checkDigit == 0) : (checkDigit == (11 - remainder))
  }
}
