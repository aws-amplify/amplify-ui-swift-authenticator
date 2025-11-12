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
        
        // Set up mock user for post-sign-in flow
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(username: "testuser", userId: "test-user-id")
        // Set up empty attributes (user is verified)
        authenticationService.mockedUnverifiedAttributes = []
    }

    override func tearDown() {
        state = nil
        authenticatorState = nil
        authenticationService = nil
    }

    /// Given: A SignInConfirmPasswordState
    /// When: confirmPassword is called with a valid password
    /// Then: The authentication service should be called and the next step should be set
    func testConfirmPassword_withValidPassword_shouldSignIn() async throws {
        state.credentials.username = "testuser"
        state.password = "ValidPassword123!"
        
        authenticationService.confirmSignInHandler = { challengeResponse, options in
            XCTAssertEqual(challengeResponse, "ValidPassword123!")
            return AuthSignInResult(nextStep: .done)
        }

        try await state.confirmPassword()

        XCTAssertEqual(authenticationService.confirmSignInCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
    }

    /// Given: A SignInConfirmPasswordState
    /// When: confirmPassword is called and the service returns an error
    /// Then: An error message should be set
    func testConfirmPassword_withInvalidPassword_shouldSetErrorMessage() async {
        state.password = "WrongPassword"
        
        authenticationService.confirmSignInHandler = { _, _ in
            throw AuthError.service("Invalid password", "", nil)
        }

        do {
            try await state.confirmPassword()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(state.message)
        }

        XCTAssertEqual(authenticationService.confirmSignInCount, 1)
    }

    /// Given: A SignInConfirmPasswordState
    /// When: confirmPassword is called with an empty password
    /// Then: The authentication service should still be called (validation happens in view)
    func testConfirmPassword_withEmptyPassword_shouldCallService() async throws {
        state.password = ""
        
        authenticationService.confirmSignInHandler = { challengeResponse, options in
            XCTAssertEqual(challengeResponse, "")
            return AuthSignInResult(nextStep: .done)
        }

        try await state.confirmPassword()

        XCTAssertEqual(authenticationService.confirmSignInCount, 1)
    }

    /// Given: A SignInConfirmPasswordState
    /// When: confirmPassword is called and returns a multi-step flow
    /// Then: The next step should be properly handled
    func testConfirmPassword_withMultiStepFlow_shouldHandleNextStep() async throws {
        state.password = "ValidPassword123!"
        
        authenticationService.confirmSignInHandler = { _, _ in
            return AuthSignInResult(
                nextStep: .confirmSignInWithOTP(
                    AuthCodeDeliveryDetails(destination: .email("test@example.com"))
                )
            )
        }

        try await state.confirmPassword()

        XCTAssertEqual(authenticationService.confirmSignInCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .confirmSignInWithOTP = currentStep else {
            XCTFail("Expected confirmSignInWithOTP, was \(currentStep)")
            return
        }
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
