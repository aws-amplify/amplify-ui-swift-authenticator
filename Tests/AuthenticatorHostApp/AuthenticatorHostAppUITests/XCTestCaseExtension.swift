//
//  File.swift
//  AuthenticatorHostAppUITests
//
//  Created by Singh, Harshdeep on 2023-09-21.
//

import XCTest

extension XCTestCase {

    func assertSnapshot(
        named name: String? = nil,
        snapshotDirectory: String? = nil,
        timeout: TimeInterval = 5,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        let result = Snapshot().captureAndVerifySnapshot(
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

}
