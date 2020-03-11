//
//  CornholeUITests.swift
//  CornholeUITests
//
//  Created by Alex Wong on 3/6/20.
//  Copyright © 2020 Kids Can Code. All rights reserved.
//

import XCTest

class CornholeUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app = XCUIApplication()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app.launchArguments.append("--uitesting")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBasicGame() {
        // UI tests must launch the application that they test.
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        passHelp()
        login(red1: "Alex", red2: "Bob", blue1: "Carol", blue2: "Danny")
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func passHelp() {
        for _ in 0..<12 {
            app.tap()
        }
    }
    
    func login(red1: String, red2: String?, blue1: String, blue2: String?) {
        app.buttons["SelectRed1P"].tap()
        app.textFields["NewPlayerNameP"].tap()
        app.textFields["NewPlayerNameP"].typeText(red1)
        app.buttons["AddNewPlayerP"].tap()
        app.buttons["SelectBlue1P"].tap()
        app.textFields["NewPlayerNameP"].tap()
        app.textFields["NewPlayerNameP"].typeText(blue1)
        app.buttons["AddNewPlayerP"].tap()
        if red2 != nil {
            app.segmentedControls["NumberOfPlayersP"].buttons["2 v 2"].tap()
            app.buttons["SelectRed2P"].tap()
            app.textFields["NewPlayerNameP"].tap()
            app.textFields["NewPlayerNameP"].typeText(red2!)
            app.buttons["AddNewPlayerP"].tap()
            app.buttons["SelectBlue2P"].tap()
            app.textFields["NewPlayerNameP"].tap()
            app.textFields["NewPlayerNameP"].typeText(blue2!)
            app.buttons["AddNewPlayerP"].tap()
        }
    }
}
