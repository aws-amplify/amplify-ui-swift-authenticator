//
//  File.swift
//  AuthenticatorHostAppUITests
//
//  Created by Singh, Harshdeep on 2023-09-21.
//

import XCTest

class AuthenticatorBaseTestCase: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        XCUIApplication().terminate()
    }

    func assertSnapshot(
        named name: String? = nil,
        snapshotDirectory: String? = nil,
        timeout: TimeInterval = 5,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        let result = Snapshotter.captureAndVerifySnapshot(
            for: XCUIApplication().screenshot().image,
            named: name,
            snapshotDirectory: snapshotDirectory,
            timeout: timeout,
            file: file,
            testName: testName,
            line: line)

        // Add the attachments to the test case
        result.attachments.forEach( {add($0) })
        
        XCTAssertTrue(
            result.didSucceed,
            "Snapshot Assertion failed for test. Description:\n\n\(result.message ?? "No description")")
    }

    func launchApp(with args: [ProcessArgument]) {
        // Launch Application
        let app = XCUIApplication()

        if let encodedData = try? JSONEncoder().encode(args),
           let stringJSON = String(data: encodedData, encoding: .utf8) {
            app.launchArguments = [
                "-uiTestArgsData", stringJSON,
            ]
        } else {
            print("Unable to encode process args")
        }

        app.launch()
    }

    func launchAppAndLogin(with args: [ProcessArgument]) {

        // Launch Application
        launchApp(with: args)
        // Get app instance
        let app = XCUIApplication()

        // Enter some username
        app.textFields.firstMatch.tap()
        app.textFields.firstMatch.typeText("username")

        // Enter some password
        app.secureTextFields.firstMatch.tap()
        app.secureTextFields.firstMatch.typeText("password")

        // Tap Sign in button
        app.buttons["Sign In"].firstMatch.tap()

        // Wait for Sign In view to disappear
        let expectation = expectation(
            for: .init(format: "exists == false"),
            evaluatedWith: app.staticTexts["Sign In"])
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(result, .completed)
    }

}
