//
//  YukoMyNumberAppUITests.swift
//  YukoMyNumberAppUITests
//
//  Created by 木村正徳 on 2016/01/05.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import XCTest

class YukoMyNumberAppUITests: XCTestCase {
  
  fileprivate let testEmployeeCode:String = "1000136"
  fileprivate let testEmployeeFamilyName = "木村"
  fileprivate let testEmployeeFirstName = "正徳"
  fileprivate let testPassCode = "1234"
  
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
      
      //for (var i = 1; i <= 2;i++) {
        let app = XCUIApplication()
        app.navigationBars["RegisteredList"].buttons["Add"].tap()
        
        let tablesQuery2 = app.tables
        let employeeCodeTextField = tablesQuery2.textFields["EmployeeCode"]
        employeeCodeTextField.typeText("1004054")
        
        let familynameTextField = tablesQuery2.textFields["FamilyName"]
        familynameTextField.tap()
        familynameTextField.typeText("てすと")
        
        let firstnameTextField = tablesQuery2.textFields["FirstName"]
        firstnameTextField.tap()
        firstnameTextField.typeText("太郎")

        let tablesQuery = tablesQuery2
        tablesQuery.staticTexts["tap to select"].tap()
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "d"
        tablesQuery.pickerWheels[dateformatter.string(from: Date())].adjust(toPickerWheelValue: "1")
        
        dateformatter.dateFormat = "MMMM"
        tablesQuery.pickerWheels[dateformatter.string(from: Date())].adjust(toPickerWheelValue: "April")
        
        dateformatter.dateFormat = "yyyy"
        tablesQuery.pickerWheels[dateformatter.string(from: Date())].adjust(toPickerWheelValue: "2017")
 
        app.navigationBars["NewEmployee"].buttons["Done"].tap()
        
      //}
    }
  
  /* 社員番号編集1 */
  func testEmployeeCodeEdit(){
    
    let app = XCUIApplication()
    let tablesQuery = app.tables
    tablesQuery.staticTexts["Kimura1\u{3000}Masanori"].tap()
    tablesQuery.staticTexts["1000133"].tap()
    tablesQuery.children(matching: .cell).element(boundBy: 0).children(matching: .textField).element.tap()
    tablesQuery.buttons["\u{30c6}\u{30ad}\u{30b9}\u{30c8}\u{3092}\u{6d88}\u{53bb}"].tap()
    
    let tablesQuery2 = app.tables
    let employeeCodeTextField = tablesQuery2.textFields["EmployeeCode"]
    employeeCodeTextField.typeText("1000132")
    
    //app.navigationBars["EmployeeCode"].buttons["EditEmployee"].tap()
    app.navigationBars["EmployeeCode"].buttons["Edit"].tap()
  }
  
  /* 
  * 社員番号編集2
  */
  func testEmployeeCodeEdit2(){
    
    let app = XCUIApplication()
    let tablesQuery = app.tables
    tablesQuery.staticTexts["Kimura1\u{3000}Masanori"].tap()
    tablesQuery.staticTexts["1000133"].tap()
    tablesQuery.children(matching: .cell).element(boundBy: 0).children(matching: .textField).element.tap()
    tablesQuery.buttons["\u{30c6}\u{30ad}\u{30b9}\u{30c8}\u{3092}\u{6d88}\u{53bb}"].tap()
    
    let tablesQuery2 = app.tables
    let employeeCodeTextField = tablesQuery2.textFields["EmployeeCode"]
    employeeCodeTextField.typeText("1000131")
    
    //app.navigationBars["EmployeeCode"].buttons["EditEmployee"].tap()
    app.navigationBars["EmployeeCode"].buttons["Edit"].tap()
  }
  
  func testAddFaimily(){
    
    let app = XCUIApplication()
    let tablesQuery = app.tables
    tablesQuery.staticTexts["Kimura1\u{3000}Masanori"].tap()
    tablesQuery.buttons["AddFamily"].tap()
    
    let tablesQuery2 = app.tables
    let familynameTextField = tablesQuery2.textFields["FamilyName"]
    familynameTextField.tap()
    familynameTextField.typeText("kimura")

    let firstnameTextField = tablesQuery2.textFields["FirstName"]
    firstnameTextField.tap()
    firstnameTextField.typeText("shiro")
    
    
    //let budget = NSPredicate(format: "label BEGINSWITH 'SelectRelation'")
    
    //let budgetPicker = app.pickerWheels.elementMatchingPredicate(budget)
    app.pickerWheels["SelectRelation,-1"].adjust(toPickerWheelValue: "Son4")
    
    tablesQuery2.buttons["Done"].tap()
    
  }
  
    /*
    * 登録者削除
    */
    func testRegisterListDelete(){
      
      let app = XCUIApplication()
      app.navigationBars["RegisteredList"].buttons["編集"].tap()
      
      let tablesQuery = app.tables
      tablesQuery.buttons.element(boundBy: 0).tap()
      tablesQuery.buttons["削除"].tap()
      app.navigationBars["RegisteredList"].buttons["完了"].tap()
    }
  

  
  func testPassCode1(){
    // Failed to find matching element please file bug (bugreport.apple.com) and provide output from Console.app
    

  }
  
}
