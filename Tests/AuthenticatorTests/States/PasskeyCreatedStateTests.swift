//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import XCTest

@available(iOS 17.4, macOS 13.5, visionOS 1.0, *)
class PasskeyCreatedStateTests: XCTestCase {
    private var state: PasskeyCreatedState!
    private var authenticatorState: MockAuthenticatorState!
    private var authenticationService: MockAuthenticationService!

    override func setUp() {
        state = PasskeyCreatedState(credentials: Credentials())
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

    /// Given: A PasskeyCreatedState
    /// When: continue is called with no unverified attributes
    /// Then: Should transition to signedIn step
    func testContinue_withNoUnverifiedAttributes_shouldTransitionToSignedIn() async throws {
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "username",
            userId: "userId"
        )
        authenticationService.mockedUnverifiedAttributes = []
        
        try await state.continue()
        
        XCTAssertEqual(authenticationService.fetchUserAttributesCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .signedIn(_) = currentStep else {
            XCTFail("Expected signedIn, was \(currentStep)")
            return
        }
    }

    /// Given: A PasskeyCreatedState
    /// When: continue is called with unverified attributes
    /// Then: Should transition to verifyUser step
    func testContinue_withUnverifiedAttributes_shouldTransitionToVerifyUser() async throws {
        authenticationService.mockedUnverifiedAttributes = [
            AuthUserAttribute(.phoneNumberVerified, value: "false")
        ]
        
        try await state.continue()
        
        XCTAssertEqual(authenticationService.fetchUserAttributesCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .verifyUser(let attributes) = currentStep else {
            XCTFail("Expected verifyUser, was \(currentStep)")
            return
        }
        XCTAssertEqual(attributes, [.phoneNumber])
    }

    /// Given: A PasskeyCreatedState
    /// When: continue is called and the service returns an error
    /// Then: An error message should be set
    func testContinue_withError_shouldSetErrorMessage() async {
        authenticationService.mockedUnverifiedAttributes = []
        // Make getCurrentUser throw an error
        authenticationService.mockedCurrentUser = nil
        
        do {
            try await state.continue()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(state.message)
        }
    }
}
