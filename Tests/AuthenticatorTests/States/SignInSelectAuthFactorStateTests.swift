//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import XCTest

class SignInSelectAuthFactorStateTests: XCTestCase {
    private var state: SignInSelectAuthFactorState!
    private var authenticatorState: MockAuthenticatorState!
    private var authenticationService: MockAuthenticationService!

    override func setUp() {
        let availableAuthFactors: [AuthFactor] = [.password(), .emailOtp]
        state = SignInSelectAuthFactorState(
            credentials: Credentials(),
            availableAuthFactors: availableAuthFactors
        )
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

    // TODO: Implement test for selectAuthFactor with password
    func testSelectAuthFactor_withPassword_shouldSignIn() async throws {
        // TODO: Mock sign-in with password
        // state.selectedAuthFactor = .password()
        // state.password = "password123"
        // try await state.selectAuthFactor()
        // XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }

    // TODO: Implement test for selectAuthFactor with email OTP
    func testSelectAuthFactor_withEmailOtp_shouldSendOtp() async throws {
        // TODO: Mock OTP sending
        // state.selectedAuthFactor = .emailOtp
        // try await state.selectAuthFactor()
        // XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }

    // TODO: Implement test for selectAuthFactor with SMS OTP
    func testSelectAuthFactor_withSmsOtp_shouldSendOtp() async throws {
        // TODO: Mock OTP sending
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }

    // TODO: Implement test for selectAuthFactor with WebAuthn
    func testSelectAuthFactor_withWebAuthn_shouldInitiateWebAuthn() async throws {
        // TODO: Mock WebAuthn flow
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }

    // TODO: Implement test for selectAuthFactor with no selection
    func testSelectAuthFactor_withNoSelection_shouldFail() async throws {
        // TODO: Verify error when no auth factor is selected
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }

    // TODO: Implement test for selectAuthFactor with error
    func testSelectAuthFactor_withError_shouldSetErrorMessage() async throws {
        // TODO: Mock error response
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }

    func testUsername_shouldReturnCredentialsUsername() {
        state.credentials.username = "testuser"
        XCTAssertEqual(state.username, "testuser")
    }

    func testAvailableAuthFactors_shouldReturnProvidedFactors() {
        XCTAssertEqual(state.availableAuthFactors.count, 2)
        XCTAssertTrue(state.availableAuthFactors.contains(where: { 
            if case .password = $0 { return true }
            return false
        }))
        XCTAssertTrue(state.availableAuthFactors.contains(.emailOtp))
    }

    func testMove_shouldCallAuthenticatorStateMove() {
        state.move(to: .signUp)
        XCTAssertEqual(authenticatorState.moveToCount, 1)
        XCTAssertEqual(authenticatorState.moveToValue, .signUp)
    }
}
