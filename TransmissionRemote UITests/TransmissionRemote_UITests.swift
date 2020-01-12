//
//  TransmissionRemote_UITests.swift
//  TransmissionRemote UITests
//
//  Created by Selim Mustafaev on 03.01.2020.
//  Copyright © 2020 selim mustafaev. All rights reserved.
//

import XCTest

class TransmissionRemote_UITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	/*
    func testExample() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
		app.launchEnvironment = ["isUITest": "true", "test": "none"]
        app.launch()
		
		// The whole point of this "test" is actually profiling the app with fake API responses (see Api.setupStubs() method)
		// That way we can simulate any number of torrents and see where it gets slow
		// So, just wait here for a few minutes, while collecting info for the profiler
		let expectation = XCTestExpectation()
		wait(for: [expectation], timeout: 500)
    }
	*/
    
	// Test adding/removing torrents
	// Change from 0..<10 to 1..<12 (remove first torrent, and add two new to the end)
    func testAddRemove() {
        let app = XCUIApplication()
        app.launchEnvironment = ["isUITest": "true", "test": "diff"]
        app.launch()

        let torrentsTable = app.tables["torrents_table"]

		var observableResult = torrentsTable.tableRows.allElementsBoundByIndex.map { $0.cells.firstMatch.label }
		var idealResult = (0..<10).map { "Test torrent \($0)" }
        XCTAssert(observableResult == idealResult)

		wait(for: 6)
		observableResult = torrentsTable.tableRows.allElementsBoundByIndex.map { $0.cells.firstMatch.label }
		idealResult = (1..<12).map { "Test torrent \($0)" }
        XCTAssert(observableResult == idealResult)
    }
	
	func testSort() {
        let app = XCUIApplication()
        app.launchEnvironment = ["isUITest": "true", "test": "sort"]
        app.launch()
		
		wait(for: 6)
		
		let torrentsTable = app.tables["torrents_table"]
		let nameButton = app.tables["torrents_table"].buttons["Name"]
		nameButton.click()
		
		wait(for: 3)
		
		let observableResult = torrentsTable.tableRows.allElementsBoundByIndex.map { $0.cells.firstMatch.label }
		let idealResult = [0,1,2,3,4,5,55,6,7,8].map { "Test torrent \($0)" }
		XCTAssert(observableResult == idealResult)
		
		//wait(for: 60)
	}
}
