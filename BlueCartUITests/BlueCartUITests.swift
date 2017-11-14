//
//  BlueCartUITests.swift
//  BlueCartUITests
//
//  Created by David Rothschild on 11/6/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import XCTest

let RECIPE_TVC_UITEST = "recipeTableVC"

class BlueCartUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    func testShowTopRated() {
        XCUIApplication().launch()
        let app = XCUIApplication()
        let label = app.staticTexts["Perfect Iced Coffee"]
        self.waitForElementToAppear(element: label)
        XCTAssert(app.staticTexts["Perfect Iced Coffee"].exists)
    }
    
    func testRecipeTableVCisDisplaying() {
        XCUIApplication().launch()
        let app = XCUIApplication()
        XCTAssert(app.isDisplayingRecipeTableVC)
    }
    

    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func waitForElementToAppear(element: XCUIElement, timeout: TimeInterval = 5,  file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        
        expectation(for: existsPredicate,
                    evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: timeout) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(timeout) seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: Int(line), expected: true)
            }
        }
    }
    
}

/// For UI testing
extension XCUIApplication {
    var isDisplayingRecipeTableVC: Bool {
        return otherElements[RECIPE_TVC_UITEST].exists
    }
}

