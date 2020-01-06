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

    func testExample() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
		app.launchEnvironment = ["isUITest": "true"]
        app.launch()
		
		// The whole point of this "test" is actually profiling the app with fake API responses (see Api.setupStubs() method)
		// That way we can simulate any number of torrents and see where it gets slow
		// So, just wait here for a few minutes, while collecting info for the profiler
		let expectation = XCTestExpectation()
		wait(for: [expectation], timeout: 500)
    }
}
