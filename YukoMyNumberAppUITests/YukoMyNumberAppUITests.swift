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
  
    /* 新規登録 ノーマル */
    func testRegisterEmployee(){
      
      let app = XCUIApplication()
      app.navigationBars["RegisteredList"].buttons["Add"].tap()
      
      let tablesQuery2 = app.tables
      let employeeCodeTextField = tablesQuery2.textFields["EmployeeCode"]
      employeeCodeTextField.typeText(testEmployeeCode)
      
      let familynameTextField = tablesQuery2.textFields["FamilyName"]
      familynameTextField.tap()
      familynameTextField.typeText("Kimura")
      
      let firstnameTextField = tablesQuery2.textFields["FirstName"]
      firstnameTextField.tap()
      firstnameTextField.typeText("Masanori")
      
      let tablesQuery = tablesQuery2
      tablesQuery.staticTexts["tap to select"].tap()

      let dateformatter = NSDateFormatter()

      dateformatter.dateFormat = "d"
      tablesQuery.pickerWheels[dateformatter.stringFromDate(NSDate())].adjustToPickerWheelValue("1")
      
      dateformatter.dateFormat = "MMMM"
      tablesQuery.pickerWheels[dateformatter.stringFromDate(NSDate())].adjustToPickerWheelValue("April")
      
      dateformatter.dateFormat = "yyyy"
      tablesQuery.pickerWheels[dateformatter.stringFromDate(NSDate())].adjustToPickerWheelValue("2017")
      
      app.navigationBars["NewEmployee"].buttons["Done"].tap()
      
    }

  
    /*
    * 登録者削除
    */
    func testRegisterListDelete(){
      
      let app = XCUIApplication()
      app.navigationBars["RegisteredList"].buttons["Edit"].tap()
      
      let tablesQuery = app.tables
      tablesQuery.buttons.elementBoundByIndex(0).tap()
      tablesQuery.buttons["Delete"].tap()
      app.navigationBars["RegisteredList"].buttons["Done"].tap()
    }
    
    func testEmployeeCodeEdit(){

      let app = XCUIApplication()
      app.tables.childrenMatchingType(.Cell).elementBoundByIndex(0).tap()
      
      let tablesQuery = app.tables
      tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(0).staticTexts[testEmployeeCode].tap()

      tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(0).childrenMatchingType(.TextField).element.tap()
      
      let tablesQuery2 = tablesQuery
      tablesQuery2.buttons["Clear text"].tap()

      let employeeCodeTextField = tablesQuery.textFields["社員番号"]
      employeeCodeTextField.typeText("1000136")
      app.navigationBars["EmployeeCode"].buttons["EditEmployee"].tap()
      
      
    }
  
  func testPassCode1(){
    // Failed to find matching element please file bug (bugreport.apple.com) and provide output from Console.app
    
    
    
    
    
  }
  
}
