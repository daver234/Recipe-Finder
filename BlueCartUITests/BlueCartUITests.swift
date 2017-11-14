//
//  BlueCartUITests.swift
//  BlueCartUITests
//
//  Created by David Rothschild on 11/6/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import XCTest

let RECIPE_TVC_UITEST = "recipeTableVC"
let RECIPE_CELL = "RecipeCell"

class BlueCartUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        // XCUIApplication().launch()
        app = XCUIApplication()

        /// Sending a command line agrument to the app to enable it to reset its state
        app.launchArguments.append("--uitesting")
    }
    
    /// So far, one of the top rated recipes has been this one. So check for it.
    func testShowTopRated() {
        app.launch()
        let label = app.staticTexts["Perfect Iced Coffee"]
        self.waitForElementToAppear(element: label)
        XCTAssert(app.staticTexts["Perfect Iced Coffee"].exists)
    }
    
    
    /// Checks to see if accessability indicator is present in ReceipeTableVC
    /// Indicator is set in ViewDidLoad
    /// If there, then the app launched.
    func testRecipeTableVCisDisplaying() {
        XCUIApplication().launch()
        let appNew = XCUIApplication()
        XCTAssert(appNew.isDisplayingRecipeTableVC)
    }
    
    /// Launch app, tap search bar, enter text "apple", tap cancel
    func testSearchBar() {
        XCUIApplication().launch()
        let appNew = XCUIApplication()
        appNew/*@START_MENU_TOKEN@*/.tables/*[[".otherElements[\"recipeTableVC\"].tables",".tables"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.searchFields["Search for recipes..."].tap()
        appNew.searchFields["Search for recipes..."].typeText("apple")
        appNew.buttons["Cancel"].tap()
        
    }

    /// Tap on a cell, go to RecipeDetail, tap a check mark, then tap Back
    /// to go back to main RecipeTableVC
    func testTapCell() {
        XCUIApplication().launch()
        let appNew = XCUIApplication()
        appNew/*@START_MENU_TOKEN@*/.tables.staticTexts["Jalapeno Popper Grilled Cheese Sandwich"]/*[[".otherElements[\"recipeTableVC\"].tables",".cells.staticTexts[\"Jalapeno Popper Grilled Cheese Sandwich\"]",".staticTexts[\"Jalapeno Popper Grilled Cheese Sandwich\"]",".tables"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        appNew.tables.cells.containing(.staticText, identifier:"2 jalapeno peppers, cut in half lengthwise and seeded").children(matching: .other).element(boundBy: 0).tap()
        appNew.navigationBars["Recipe"].buttons["Back"].tap()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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

