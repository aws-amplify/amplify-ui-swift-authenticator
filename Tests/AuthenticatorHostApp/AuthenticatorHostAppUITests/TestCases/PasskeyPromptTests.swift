//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest

final class PasskeyPromptTests: AuthenticatorBaseTestCase {
    
    func testSignInPasskeyPrompt() throws {
        launchAppAndLogin(with: [
            .hidesSignUpButton(false),
            .initialStep(.signIn),
            .authSignInStep(.done)
        ])
        assertSnapshot()
    }
    
    func testSignUpPasskeyPrompt() throws {
        
        let app = XCUIApplication()
        
        launchApp(with: [
            .hidesSignUpButton(false),
            .initialStep(.signUp),
            .authSignInStep(.done),
            .passwordlessFlow(true)
        ])
        
        // Enter some username
        app.textFields.firstMatch.tap()
        app.textFields.firstMatch.typeText("username")

        // Enter some username
        app.textFields["Enter your email"].tap()
        app.textFields["Enter your email"].typeText("username@username.com")
        
        // Tap Sign in button
        app.buttons["Create account"].firstMatch.tap()
        
        // Wait for Sign In view to disappear
        let expectation = expectation(
            for: .init(format: "exists == false"),
            evaluatedWith: app.staticTexts["Create account"])
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(result, .completed)
        
        assertSnapshot()
    }
    
    func testSignInPasskeyCreated() throws {
        launchAppAndLogin(with: [
            .hidesSignUpButton(false),
            .initialStep(.signIn),
            .authSignInStep(.done)
        ])
        
        let app = XCUIApplication()
        // Tap Sign in button
        app.buttons["Create a Passkey"].firstMatch.tap()
        
        // Wait for Sign In view to disappear
        let expectation = expectation(
            for: .init(format: "exists == false"),
            evaluatedWith: app.staticTexts["Create a Passkey"])
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(result, .completed)
        
        assertSnapshot()
    }
}
