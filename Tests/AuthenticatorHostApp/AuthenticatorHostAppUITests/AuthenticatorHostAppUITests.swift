//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import UIKit

final class AuthenticatorHostAppUITests: XCTestCase {


    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        XCUIApplication().terminate()
    }

    func testSignInViewWithWithUsernameAsPhoneNumber() throws {
        launchApp(with: [
            ProcessArgument.hidesSignUpButton(false),
            ProcessArgument.initialStep(.signIn)
        ])
        assertSnapshot()
    }

    func testResetPasswordView() throws {
        launchApp(with: [
            ProcessArgument.hidesSignUpButton(false),
            ProcessArgument.initialStep(.resetPassword)
        ])
        assertSnapshot()
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
