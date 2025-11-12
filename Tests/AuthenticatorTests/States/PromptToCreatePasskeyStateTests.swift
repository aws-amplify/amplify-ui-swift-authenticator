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
class PromptToCreatePasskeyStateTests: XCTestCase {
    private var state: PromptToCreatePasskeyState!
    private var authenticatorState: MockAuthenticatorState!
    private var authenticationService: MockAuthenticationService!

    override func setUp() {
        state = PromptToCreatePasskeyState(credentials: Credentials())
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

    /// Given: A PromptToCreatePasskeyState
    /// When: createPasskey is called successfully
    /// Then: Should transition to passkeyCreated step
    func testCreatePasskey_withSuccess_shouldTransitionToPasskeyCreated() async throws {
        // Mock successful passkey creation (no error thrown)
        authenticationService.mockedAssociateWebAuthnCredentialError = nil
        
        try await state.createPasskey()
        
        XCTAssertEqual(authenticationService.associateWebAuthnCredentialCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .passkeyCreated = currentStep else {
            XCTFail("Expected passkeyCreated, was \(currentStep)")
            return
        }
    }

    /// Given: A PromptToCreatePasskeyState
    /// When: createPasskey is called and the service returns an error
    /// Then: An error message should be set
    func testCreatePasskey_withError_shouldSetErrorMessage() async {
        authenticationService.mockedAssociateWebAuthnCredentialError = AuthError.service(
            "Passkey creation failed",
            "",
            nil
        )
        
        do {
            try await state.createPasskey()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(state.message)
        }
        
        XCTAssertEqual(authenticationService.associateWebAuthnCredentialCount, 1)
    }

    /// Given: A PromptToCreatePasskeyState
    /// When: createPasskey is called and user cancels
    /// Then: Should handle cancellation gracefully with error message
    func testCreatePasskey_withUserCancellation_shouldHandleGracefully() async {
        authenticationService.mockedAssociateWebAuthnCredentialError = AuthError.service(
            "User cancelled passkey creation",
            "",
            nil
        )
        
        do {
            try await state.createPasskey()
            XCTFail("Expected error to be thrown")
        } catch {
            // Wait for message to be set on main actor
            await MainActor.run {
                XCTAssertNotNil(state.message)
            }
        }
        
        XCTAssertEqual(authenticationService.associateWebAuthnCredentialCount, 1)
    }

    /// Given: A PromptToCreatePasskeyState
    /// When: skip is called with no unverified attributes
    /// Then: Should transition to signedIn step
    func testSkip_withNoUnverifiedAttributes_shouldTransitionToSignedIn() async throws {
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "username",
            userId: "userId"
        )
        authenticationService.mockedUnverifiedAttributes = []
        
        try await state.skip()
        
        XCTAssertEqual(authenticationService.fetchUserAttributesCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .signedIn(_) = currentStep else {
            XCTFail("Expected signedIn, was \(currentStep)")
            return
        }
    }

    /// Given: A PromptToCreatePasskeyState
    /// When: skip is called with unverified attributes
    /// Then: Should transition to verifyUser step
    func testSkip_withUnverifiedAttributes_shouldTransitionToVerifyUser() async throws {
        authenticationService.mockedUnverifiedAttributes = [
            AuthUserAttribute(.emailVerified, value: "false")
        ]
        
        try await state.skip()
        
        XCTAssertEqual(authenticationService.fetchUserAttributesCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .verifyUser(let attributes) = currentStep else {
            XCTFail("Expected verifyUser, was \(currentStep)")
            return
        }
        XCTAssertEqual(attributes, [.email])
    }

    /// Given: A PromptToCreatePasskeyState
    /// When: skip is called and the service returns an error
    /// Then: An error message should be set
    func testSkip_withError_shouldSetErrorMessage() async {
        authenticationService.mockedUnverifiedAttributes = []
        // Make getCurrentUser throw an error
        authenticationService.mockedCurrentUser = nil
        
        do {
            try await state.skip()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(state.message)
        }
    }
}
