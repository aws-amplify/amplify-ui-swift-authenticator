//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import XCTest

class SignInConfirmPasswordStateTests: XCTestCase {
    private var state: SignInConfirmPasswordState!
    private var authenticatorState: MockAuthenticatorState!
    private var authenticationService: MockAuthenticationService!

    override func setUp() {
        state = SignInConfirmPasswordState(credentials: Credentials())
        authenticatorState = MockAuthenticatorState()
        authenticationService = MockAuthenticationService()
        authenticatorState.authenticationService = authenticationService
        state.configure(with: authenticatorState)
    }

    override func tearDown() {
        state = nil
        authenticatorState = nil
        authenticationService = nil
    }

    // TODO: Implement test for confirmPassword with valid password
    func testConfirmPassword_withValidPassword_shouldSignIn() async throws {
        // TODO: Mock successful password confirmation
        // state.password = "password123"
        // authenticationService.mockedSignInResult = .init(nextStep: .done)
        // authenticationService.mockedCurrentUser = MockAuthenticationService.User(
        //     username: "username",
        //     userId: "userId"
        // )
        // try await state.confirmPassword()
        // XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }

    // TODO: Implement test for confirmPassword with invalid password
    func testConfirmPassword_withInvalidPassword_shouldSetErrorMessage() async throws {
        // TODO: Mock error response
        // state.password = "wrongpassword"
        // do {
        //     try await state.confirmPassword()
        //     XCTFail("Should not succeed")
        // } catch {
        //     guard let authenticatorError = error as? AuthenticatorError else {
        //         XCTFail("Expected AuthenticatorError")
        //         return
        //     }
        //     let task = Task { @MainActor in
        //         XCTAssertNotNil(state.message)
        //         XCTAssertEqual(state.message?.content, authenticatorError.content)
        //     }
        //     await task.value
        // }
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }

    // TODO: Implement test for confirmPassword with empty password
    func testConfirmPassword_withEmptyPassword_shouldFail() async throws {
        // TODO: Verify error when password is empty
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }

    func testUsername_shouldReturnCredentialsUsername() {
        state.credentials.username = "testuser"
        XCTAssertEqual(state.username, "testuser")
    }

    func testPassword_shouldUpdateCredentials() {
        state.password = "newpassword"
        XCTAssertEqual(state.credentials.password, "newpassword")
    }

    func testMove_shouldCallAuthenticatorStateMove() {
        state.move(to: .signUp)
        XCTAssertEqual(authenticatorState.moveToCount, 1)
        XCTAssertEqual(authenticatorState.moveToValue, .signUp)
    }
}
