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
            // Wait for message to be set on main actor
            await MainActor.run {
                XCTAssertNotNil(state.message)
            }
        }
    }
    
    /// Given: A PasskeyCreatedState
    /// When: fetchPasskeyCredentials is called
    /// Then: Should fetch and populate passkey credentials
    func testPasskeyMetadata_shouldBeAvailable() async {
        // Mock passkey credentials
        let credential1 = MockWebAuthnCredential(
            credentialId: "cred1",
            friendlyName: "iPhone 15 Pro",
            relyingPartyId: "example.com",
            createdAt: Date()
        )
        authenticationService.mockedWebAuthnCredentials = [credential1]
        
        await state.fetchPasskeyCredentials()
        
        XCTAssertEqual(authenticationService.listWebAuthnCredentialsCount, 1)
        
        await MainActor.run {
            XCTAssertEqual(state.passkeyCredentials.count, 1)
            XCTAssertEqual(state.passkeyCredentials.first?.credentialId, "cred1")
            XCTAssertEqual(state.passkeyCredentials.first?.friendlyName, "iPhone 15 Pro")
        }
    }
    
    /// Given: A PasskeyCreatedState
    /// When: fetchPasskeyCredentials is called with multiple passkeys
    /// Then: Should fetch and display all passkeys
    func testMultiplePasskeys_shouldBeSupported() async {
        // Mock multiple passkey credentials
        let credential1 = MockWebAuthnCredential(
            credentialId: "cred1",
            friendlyName: "iPhone 15 Pro",
            relyingPartyId: "example.com",
            createdAt: Date()
        )
        let credential2 = MockWebAuthnCredential(
            credentialId: "cred2",
            friendlyName: "MacBook Pro",
            relyingPartyId: "example.com",
            createdAt: Date()
        )
        let credential3 = MockWebAuthnCredential(
            credentialId: "cred3",
            friendlyName: "iPad Air",
            relyingPartyId: "example.com",
            createdAt: Date()
        )
        authenticationService.mockedWebAuthnCredentials = [credential1, credential2, credential3]
        
        await state.fetchPasskeyCredentials()
        
        XCTAssertEqual(authenticationService.listWebAuthnCredentialsCount, 1)
        
        await MainActor.run {
            XCTAssertEqual(state.passkeyCredentials.count, 3)
            XCTAssertEqual(state.passkeyCredentials[0].friendlyName, "iPhone 15 Pro")
            XCTAssertEqual(state.passkeyCredentials[1].friendlyName, "MacBook Pro")
            XCTAssertEqual(state.passkeyCredentials[2].friendlyName, "iPad Air")
        }
    }
}
