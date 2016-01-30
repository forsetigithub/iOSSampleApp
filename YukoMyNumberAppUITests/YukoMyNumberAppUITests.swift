//
//  YukoMyNumberAppUITests.swift
//  YukoMyNumberAppUITests
//
//  Created by 木村正徳 on 2016/01/05.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import XCTest

class YukoMyNumberAppUITests: XCTestCase {
  
  private let testEmployeeCode:String = "1000136"
  private let testEmployeeFamilyName = "木村"
  private let testEmployeeFirstName = "正徳"
  private let testPassCode = "1234"
  
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {

      
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
  
  func testYukoMyNumberApp(){
    

    
  
  }
  
  
  func testRegisterEmployee2(){
    

  }
  
  /* 
  * 新規登録
  */
  func testRegisterEmployee(){
    
    let app = XCUIApplication()
    let navigationBar = app.navigationBars["登録者一覧"]
    navigationBar.buttons["追加"].tap()
    
    let tablesQuery = app.tables
    
    
    //正常パターン
    //let clearTextTextField = tablesQuery.textFields.containingType(.Button, identifier:"Clear text").element
    
    let textField3 = tablesQuery.textFields["社員番号"]
    textField3.typeText(testEmployeeCode)

    let textField = tablesQuery.textFields["姓"]
    textField.tap()
    textField.typeText(testEmployeeFamilyName)

    let textField2 = tablesQuery.textFields["名"]
    textField2.tap()
    textField2.typeText(testEmployeeFirstName)
    
    tablesQuery.staticTexts["入社年月日"].tap()
    let dateformatter = NSDateFormatter()
    dateformatter.dateFormat = "yyyy年"
    
    tablesQuery.pickerWheels[dateformatter.stringFromDate(NSDate())].adjustToPickerWheelValue("2017年")
    
    dateformatter.dateFormat = "M月"
    tablesQuery.pickerWheels[dateformatter.stringFromDate(NSDate())].adjustToPickerWheelValue("4月")
    
    dateformatter.dateFormat = "d日"
    tablesQuery.pickerWheels[dateformatter.stringFromDate(NSDate())].adjustToPickerWheelValue("1日")
    
    app.navigationBars["入社年月日"].buttons["新規登録"].tap()
    
    
    let button = app.navigationBars["新規登録"].buttons["登録"]
    button.tap()
    
  }
  
  
  
  /* 
  * 登録者削除
  */
  func testRegisterListDelete(){
  
    let app = XCUIApplication()
    let navigationBar = app.navigationBars["登録者一覧"]
    navigationBar.buttons["編集"].tap()
    
    let tablesQuery = app.tables
    tablesQuery.buttons.elementBoundByIndex(0).tap()
    tablesQuery.buttons["削除"].tap()
    navigationBar.buttons["完了"].tap()
    
  }
  
  
  
  func testChangePassCode(){
    
    let app = XCUIApplication()
    app.toolbars.buttons["登録者情報"].tap()
    app.sheets["メニューを選択してください"].collectionViews.buttons["暗証番号を変更"].tap()
    
    let tablesQuery2 = app.tables
    //let tablesQuery = tablesQuery2
    tablesQuery2.childrenMatchingType(.Cell).elementBoundByIndex(0).childrenMatchingType(.SecureTextField).element.typeText("1234")
    
    tablesQuery2.childrenMatchingType(.Cell).elementBoundByIndex(1).childrenMatchingType(.SecureTextField).element.typeText("1235")

    tablesQuery2.childrenMatchingType(.Cell).elementBoundByIndex(2).childrenMatchingType(.SecureTextField).element.typeText("1235")
    app.navigationBars["変更"].tap()
    app.alerts["暗証番号変更"].collectionViews.buttons["OK"].tap()
  
  }
  
  func testShowEmployeeEdit(){
    
  
  
  }
  
}
