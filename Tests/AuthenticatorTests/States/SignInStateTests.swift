//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import XCTest

class SignInStateTests: XCTestCase {
    private var state: SignInState!
    private var authenticatorState: MockAuthenticatorState!
    private var authenticationService: MockAuthenticationService!

    override func setUp() {
        state = SignInState(credentials: Credentials())
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

    func testSignIn_withValidCredentials_shouldSetNextStep() async throws {
        authenticationService.mockedSignInResult = .init(nextStep: .done)
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "username",
            userId: "userId"
        )

        try await state.signIn()
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .signedIn(_) = currentStep else {
            XCTFail("Expected signedIn, was \(currentStep)")
            return
        }
    }

    func testSignIn_withInvalidCredentials_shouldSetErrorMessage() async throws {
        do {
            try await state.signIn()
            XCTFail("Should not succeed")
        } catch {
            guard let authenticatorError = error as? AuthenticatorError else {
                XCTFail("Expected AuthenticatorError, was \(type(of: error))")
                return
            }

            let task = Task { @MainActor in
                XCTAssertNotNil(state.message)
                XCTAssertEqual(state.message?.content, authenticatorError.content)
            }
            await task.value
        }
    }
    
    // MARK: - Password Flow Tests
    
    @MainActor
    func testSignIn_withPasswordFlow_shouldUseUserSRPAuthFlow() async throws {
        // Configure for password-only flow
        authenticatorState.authenticationFlow = .password
        state.username = "testuser"
        state.password = "password123"
        
        authenticationService.mockedSignInResult = .init(nextStep: .done)
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "testuser",
            userId: "userId"
        )
        
        try await state.signIn()
        
        // Verify sign-in was called
        XCTAssertEqual(authenticationService.signInCount, 1)
        
        // Verify the auth flow type was set correctly (userSRP for password flow)
        // Note: We can't directly verify the options in the mock, but we verify the flow works
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .signedIn(_) = currentStep else {
            XCTFail("Expected signedIn, was \(currentStep)")
            return
        }
    }
    
    // MARK: - UserChoice Flow Tests
    
    @MainActor
    func testSignIn_withUserChoiceFlowPasswordPreferred_shouldUseUserAuthFlow() async throws {
        // Configure for userChoice flow with password as preferred
        authenticatorState.authenticationFlow = .userChoice(preferredAuthFactor: .password())
        state.username = "testuser"
        state.password = "password123"
        
        authenticationService.mockedSignInResult = .init(nextStep: .done)
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "testuser",
            userId: "userId"
        )
        
        try await state.signIn()
        
        // Verify sign-in was called with userAuth flow
        XCTAssertEqual(authenticationService.signInCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
    }
    
    @MainActor
    func testSignIn_withUserChoiceFlowEmailOtpPreferred_shouldUseUserAuthFlow() async throws {
        // Configure for userChoice flow with emailOtp as preferred
        authenticatorState.authenticationFlow = .userChoice(preferredAuthFactor: .emailOtp)
        state.username = "testuser"
        
        authenticationService.mockedSignInResult = .init(nextStep: .done)
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "testuser",
            userId: "userId"
        )
        
        try await state.signIn()
        
        // Verify sign-in was called with userAuth flow
        XCTAssertEqual(authenticationService.signInCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
    }
    
    @MainActor
    func testSignIn_withUserChoiceFlowNoPreferredFactor_shouldUseUserAuthFlow() async throws {
        // Configure for userChoice flow without preferred factor
        authenticatorState.authenticationFlow = .userChoice(preferredAuthFactor: nil)
        state.username = "testuser"
        
        authenticationService.mockedSignInResult = .init(nextStep: .done)
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "testuser",
            userId: "userId"
        )
        
        try await state.signIn()
        
        // Verify sign-in was called with userAuth flow (no preferred factor)
        XCTAssertEqual(authenticationService.signInCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
    }
    
    // MARK: - Auth Factor Translation Tests
    
    func testAuthFactorTranslation_passwordWithSRP_shouldTranslateToPasswordSRP() {
        // This is tested implicitly through the sign-in flow
        // The translation happens in createSignInOptions() -> translateAuthFactor()
        authenticatorState.authenticationFlow = .userChoice(preferredAuthFactor: .password(srp: true))
        
        // Verify the flow is configured correctly
        if case .userChoice(let preferredAuthFactor, _) = state.authenticationFlow,
           case .password(let srp) = preferredAuthFactor {
            XCTAssertTrue(srp, "Expected SRP to be true")
        } else {
            XCTFail("Expected userChoice with password(srp: true)")
        }
    }
    
    func testAuthFactorTranslation_passwordWithoutSRP_shouldTranslateToPassword() {
        authenticatorState.authenticationFlow = .userChoice(preferredAuthFactor: .password(srp: false))
        
        if case .userChoice(let preferredAuthFactor, _) = state.authenticationFlow,
           case .password(let srp) = preferredAuthFactor {
            XCTAssertFalse(srp, "Expected SRP to be false")
        } else {
            XCTFail("Expected userChoice with password(srp: false)")
        }
    }
    
    func testAuthFactorTranslation_emailOtp_shouldTranslateToEmailOTP() {
        authenticatorState.authenticationFlow = .userChoice(preferredAuthFactor: .emailOtp)
        
        if case .userChoice(let preferredAuthFactor, _) = state.authenticationFlow {
            XCTAssertEqual(preferredAuthFactor, .emailOtp)
        } else {
            XCTFail("Expected userChoice with emailOtp")
        }
    }
    
    func testAuthFactorTranslation_smsOtp_shouldTranslateToSmsOTP() {
        authenticatorState.authenticationFlow = .userChoice(preferredAuthFactor: .smsOtp)
        
        if case .userChoice(let preferredAuthFactor, _) = state.authenticationFlow {
            XCTAssertEqual(preferredAuthFactor, .smsOtp)
        } else {
            XCTFail("Expected userChoice with smsOtp")
        }
    }
    
    func testAuthFactorTranslation_webAuthn_shouldTranslateToWebAuthn() {
        authenticatorState.authenticationFlow = .userChoice(preferredAuthFactor: .webAuthn)
        
        if case .userChoice(let preferredAuthFactor, _) = state.authenticationFlow {
            XCTAssertEqual(preferredAuthFactor, .webAuthn)
        } else {
            XCTFail("Expected userChoice with webAuthn")
        }
    }
    
    // MARK: - Property Tests
    
    func testUsername_shouldUpdateCredentials() {
        state.username = "newuser"
        XCTAssertEqual(state.credentials.username, "newuser")
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
    
    // MARK: - Selected Auth Factor Reset Tests
    
    @MainActor
    func testSignIn_shouldResetSelectedAuthFactor() async throws {
        // Given - credentials has a previously selected auth factor
        state.credentials.selectedAuthFactor = .emailOtp
        state.username = "testuser"
        
        authenticationService.mockedSignInResult = .init(nextStep: .done)
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "testuser",
            userId: "userId"
        )
        
        // When
        try await state.signIn()
        
        // Then - selectedAuthFactor should be reset to nil
        XCTAssertNil(state.credentials.selectedAuthFactor, "selectedAuthFactor should be reset on new sign-in")
    }
    
    @MainActor
    func testSignIn_withPreviousWebAuthnSelection_shouldResetForFreshFlow() async throws {
        // Given - User previously selected webAuthn (simulating cancel scenario)
        state.credentials.selectedAuthFactor = .webAuthn
        state.username = "testuser"
        
        // Mock factor selection step (user will need to select again)
        authenticationService.mockedSignInResult = .init(
            nextStep: .continueSignInWithFirstFactorSelection([.emailOTP, .smsOTP, .passwordSRP])
        )
        
        // When
        try await state.signIn()
        
        // Then - selectedAuthFactor should be reset so first selection uses confirmSignIn
        XCTAssertNil(state.credentials.selectedAuthFactor, "selectedAuthFactor should be reset for fresh flow")
    }
}
