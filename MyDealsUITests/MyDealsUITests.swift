//
//  MyDealsUITests.swift
//  MyDealsUITests
//
//  Created by Mathieu Corti on 8/22/17.
//  Copyright © 2017 Mathieu Corti. All rights reserved.
//

import XCTest

class MyDealsUITests: XCTestCase {
        
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
    
    func testWorkflow() {
        
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["1 free hot coffee"].tap()
        
        let mydealsButton = app.navigationBars["Deal details"].buttons["MyDeals"]
        mydealsButton.tap()
        app.navigationBars["MyDeals"].buttons["Add"].tap()
        
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        let textField = element.children(matching: .other).element(boundBy: 0).children(matching: .textField).element
        textField.tap()
        
        let shiftButton = app.buttons["shift"]
        shiftButton.tap()
        textField.typeText("Deal")
        app.otherElements["“Deal”"].tap()
        shiftButton.tap()
        textField.typeText("Great title !")
        
        let textField2 = element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
        textField2.tap()
        
        let editManuallyButton = app.sheets["Editing style"].buttons["Edit manually"]
        editManuallyButton.tap()
        textField2.typeText("https://www.apple.com/ac/structured-data/images/knowledge_graph_logo.png?201707270753")
        
        let textField3 = element.children(matching: .other).element(boundBy: 2).children(matching: .textField).element
        textField3.tap()
        editManuallyButton.tap()
        textField3.typeText("https://www.apple.com/au/")
        
        let textField4 = element.children(matching: .other).element(boundBy: 4).children(matching: .textField).element
        textField4.tap()
        textField4.typeText("Not cheap !")
        
        let textField5 = element.children(matching: .other).element(boundBy: 3).children(matching: .textField).element
        textField5.tap()
        textField5.typeText("Apple")
        element.tap()
        
        let textView = element.children(matching: .other).element(boundBy: 5).children(matching: .textView).element
        textView.tap()
        textView.typeText("Here place a great description !")
        app.staticTexts["Description *"].tap()
        app.buttons["Submit deal"].tap()
        
        tablesQuery.cells.containing(.staticText, identifier:"Deal a !").staticTexts["@Apple"].tap()
        app.buttons["Go to deal"].tap()
        app.navigationBars["Master"].buttons["Deal details"].tap()
        app.navigationBars["Deal details"].buttons["MyDeals"].tap()
        
        let mydealsNavigationBar = app.navigationBars["MyDeals"]
        mydealsNavigationBar.buttons["Edit"].tap()
        tablesQuery.buttons["Delete 30% off sport items, @Amazon"].tap()
        tablesQuery.buttons["Delete"].tap()
        mydealsNavigationBar.buttons["Done"].tap()
        
        
    }
    
}
