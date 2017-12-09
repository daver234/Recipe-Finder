//
//  BlueCartTests.swift
//  BlueCartTests
//
//  Created by David Rothschild on 11/6/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import XCTest
@testable import Recipe_Finder

class BlueCartTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testCheckMockJsonData() {
        let expectationResult = expectation(description: "Parse the test JSON Data to see if the second recipe has a name of Baked Doughnuts.")
        do {
            guard let file = Bundle.main.url(forResource: "recipes", withExtension: "json") else { return }
            let data = try Data(contentsOf: file)
            DataManager.instance.decodeDataForPage(searchString: "Test", data: data) { (response) in
                guard response else {
                    print("Error in APIManager response in testCheckMockJsonData")
                    return
                }
                print("data: ",  DataManager.instance.allRecipes[0].recipes![1].title ?? 0)
                guard let title = DataManager.instance.allRecipes[0].recipes![1].title else { return }
                print("Here is title: ", title)
                if title == "Baked Doughnuts" {
                    XCTAssertTrue(response)
                    expectationResult.fulfill()
                } else {
                    print("Error parsing local JSON data for product rating")
                }
                
            }
        } catch let jsonError {
            print("error in test case parsing mock json \(jsonError.localizedDescription)")
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
