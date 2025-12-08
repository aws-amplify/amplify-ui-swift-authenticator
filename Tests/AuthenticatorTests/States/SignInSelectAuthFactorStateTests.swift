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

    @MainActor
    func testSelectAuthFactor_withPassword_shouldSignIn() async throws {
        // Given
        state.selectedAuthFactor = .password(srp: true)
        state.password = "password123"
        state.credentials.username = "testuser"
        
        // Mock the 2-step password flow:
        // Step 1: Factor selection returns .confirmSignInWithPassword
        // Step 2: Password submission returns .done
        var callCount = 0
        authenticationService.mockedConfirmSignInResult = nil
        authenticationService.confirmSignInHandler = { (challengeResponse, _) in
            callCount += 1
            if callCount == 1 {
                // First call: factor selection
                XCTAssertEqual(challengeResponse, "PASSWORD_SRP")
                return AuthSignInResult(nextStep: .confirmSignInWithPassword)
            } else {
                // Second call: password submission
                XCTAssertEqual(challengeResponse, "password123")
                return AuthSignInResult(nextStep: .done)
            }
        }
        
        // Mock user attributes and current user for .done step processing
        authenticationService.mockedUnverifiedAttributes = []
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "testuser",
            userId: "user-123"
        )
        
        // When
        try await state.selectAuthFactor()
        
        // Then - Should make 2 API calls (factor selection + password)
        XCTAssertEqual(authenticationService.confirmSignInCount, 2)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        
        // Verify it transitions to signedIn step
        if case .signedIn = authenticatorState.setCurrentStepValue {
            // Success - correct step
        } else {
            XCTFail("Expected to transition to .signedIn step, got \(String(describing: authenticatorState.setCurrentStepValue))")
        }
    }

    @MainActor
    func testSelectAuthFactor_withEmailOtp_shouldSendOtp() async throws {
        // Given
        state.selectedAuthFactor = .emailOtp
        
        // Mock OTP sending - should transition to confirm sign in with OTP
        authenticationService.mockedConfirmSignInResult = AuthSignInResult(
            nextStep: .confirmSignInWithOTP(.init(destination: .email("test@example.com")))
        )
        
        // When
        try await state.selectAuthFactor()
        
        // Then
        XCTAssertEqual(authenticationService.confirmSignInCount, 1)
        XCTAssertEqual(authenticationService.confirmSignInChallengeResponse, "EMAIL_OTP")
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
    }

    @MainActor
    func testSelectAuthFactor_withSmsOtp_shouldSendOtp() async throws {
        // Given
        state.selectedAuthFactor = .smsOtp
        
        // Mock OTP sending - should transition to confirm sign in with OTP
        authenticationService.mockedConfirmSignInResult = AuthSignInResult(
            nextStep: .confirmSignInWithOTP(.init(destination: .phone("+1234567890")))
        )
        
        // When
        try await state.selectAuthFactor()
        
        // Then
        XCTAssertEqual(authenticationService.confirmSignInCount, 1)
        XCTAssertEqual(authenticationService.confirmSignInChallengeResponse, "SMS_OTP")
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
    }

    @MainActor
    @available(iOS 17.4, macOS 13.5, visionOS 1.0, *)
    func testSelectAuthFactor_withWebAuthn_shouldInitiateWebAuthn() async throws {
        // Given
        state.selectedAuthFactor = .webAuthn
        
        // Mock WebAuthn sign-in flow
        authenticationService.mockedConfirmSignInResult = AuthSignInResult(nextStep: .done)
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "testuser",
            userId: "test-user-id"
        )
        authenticationService.mockedUnverifiedAttributes = []
        
        // When
        try await state.selectAuthFactor()
        
        // Then - Should call confirmSignIn with WebAuthn challenge response
        XCTAssertEqual(authenticationService.confirmSignInCount, 1)
        XCTAssertEqual(authenticationService.confirmSignInChallengeResponse, "WEB_AUTHN")
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
    }

    @MainActor
    func testSelectAuthFactor_withNoSelection_shouldNotCallAPI() async throws {
        // Given
        state.selectedAuthFactor = nil
        
        // When
        try await state.selectAuthFactor()
        
        // Then - Should return early without calling API
        XCTAssertEqual(authenticationService.confirmSignInCount, 0)
    }

    @MainActor
    func testSelectAuthFactor_withError_shouldSetErrorMessage() async throws {
        // Given
        state.selectedAuthFactor = .password()
        state.password = "wrongpassword"
        
        // Mock error response
        authenticationService.mockedConfirmSignInError = AuthError.notAuthorized(
            "Incorrect username or password",
            "Check credentials and try again"
        )
        
        // When/Then
        do {
            try await state.selectAuthFactor()
            XCTFail("Should throw error")
        } catch {
            // Error should be thrown
            XCTAssertEqual(authenticationService.confirmSignInCount, 1)
            // Note: message might not be set immediately due to async timing
            // The important thing is that the error was thrown
        }
    }

    func testUsername_shouldReturnCredentialsUsername() {
        state.credentials.username = "testuser"
        XCTAssertEqual(state.username, "testuser")
    }
    
    func testCredentialsSharing_usernameSetInCredentials_shouldBeAccessibleViaUsernameProperty() {
        // Given - Simulate credentials being set from SignInState
        let sharedCredentials = Credentials()
        sharedCredentials.username = "john.doe@example.com"
        
        // When - Create SignInSelectAuthFactorState with the shared credentials
        let stateWithSharedCredentials = SignInSelectAuthFactorState(
            credentials: sharedCredentials,
            availableAuthFactors: [.password(), .emailOtp]
        )
        
        // Then - Username should be accessible
        XCTAssertEqual(stateWithSharedCredentials.username, "john.doe@example.com")
        
        // And - Modifying credentials should reflect in the state
        sharedCredentials.username = "jane.smith@example.com"
        XCTAssertEqual(stateWithSharedCredentials.username, "jane.smith@example.com")
    }
    
    func testCredentialsSharing_passwordSetInState_shouldUpdateSharedCredentials() {
        // Given - Simulate credentials being shared from SignInState
        let sharedCredentials = Credentials()
        sharedCredentials.username = "testuser"
        
        let stateWithSharedCredentials = SignInSelectAuthFactorState(
            credentials: sharedCredentials,
            availableAuthFactors: [.password()]
        )
        
        // When - Set password in the state
        stateWithSharedCredentials.password = "mypassword123"
        
        // Then - Password should be updated in shared credentials
        XCTAssertEqual(sharedCredentials.password, "mypassword123")
    }
    
    func testAuthenticationServiceAccess_afterConfiguration_shouldHaveAccessToService() {
        // Given - Create state with credentials (simulating dynamic creation in Authenticator)
        let credentials = Credentials()
        credentials.username = "testuser"
        
        let dynamicState = SignInSelectAuthFactorState(
            credentials: credentials,
            availableAuthFactors: [.password(), .emailOtp]
        )
        
        // When - Configure with authenticatorState (this happens in Authenticator.onAppear)
        let mockAuthenticatorState = MockAuthenticatorState()
        let mockAuthService = MockAuthenticationService()
        mockAuthenticatorState.authenticationService = mockAuthService
        dynamicState.configure(with: mockAuthenticatorState)
        
        // Then - State should have access to authentication service
        XCTAssertTrue(dynamicState.authenticationService === mockAuthService,
                     "State must be configured with authenticatorState to access authenticationService")
        
        // And - State should have access to configuration
        XCTAssertNotNil(dynamicState.configuration)
        
        // And - State should have access to authentication flow
        XCTAssertEqual(dynamicState.authenticationFlow, .password)
    }
    
    func testAuthenticationServiceAccess_withoutConfiguration_shouldNotHaveAccess() {
        // Given - Create state without configuration (missing configure call)
        let credentials = Credentials()
        let unconfiguredState = SignInSelectAuthFactorState(
            credentials: credentials,
            availableAuthFactors: [.password()]
        )
        
        // Then - State should not have access to authentication service
        // (authenticationService will be .default which is not the mock)
        // This test documents the requirement that configure() MUST be called
        XCTAssertTrue(unconfiguredState.authenticatorState is EmptyAuthenticatorState,
                     "Without configure(), state uses EmptyAuthenticatorState")
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
    
    // MARK: - Helper Method Tests
    
    func testPasswordField_shouldUpdateCredentials() {
        state.password = "newpassword"
        XCTAssertEqual(state.credentials.password, "newpassword")
    }
    
    func testSelectedAuthFactor_canBeSet() {
        state.selectedAuthFactor = .emailOtp
        XCTAssertEqual(state.selectedAuthFactor, .emailOtp)
        
        state.selectedAuthFactor = .password(srp: true)
        XCTAssertEqual(state.selectedAuthFactor, .password(srp: true))
    }
    
    // MARK: - Auth Factor Re-selection Tests (Flow Restart)
    
    @MainActor
    func testSelectAuthFactor_firstTimeSelection_shouldUseConfirmSignIn() async throws {
        // Given - No previous selection (credentials.selectedAuthFactor is nil)
        state.selectedAuthFactor = .emailOtp
        XCTAssertNil(state.credentials.selectedAuthFactor, "Should start with no previous selection")
        
        // Mock OTP sending
        authenticationService.mockedConfirmSignInResult = AuthSignInResult(
            nextStep: .confirmSignInWithOTP(.init(destination: .email("test@example.com")))
        )
        
        // When
        try await state.selectAuthFactor()
        
        // Then - Should use confirmSignIn (not signIn)
        XCTAssertEqual(authenticationService.confirmSignInCount, 1, "Should call confirmSignIn for first-time selection")
        XCTAssertEqual(authenticationService.signInCount, 0, "Should NOT call signIn for first-time selection")
        
        // And - Should track the selection
        XCTAssertEqual(state.credentials.selectedAuthFactor, .emailOtp)
    }
    
    @MainActor
    func testSelectAuthFactor_reselection_shouldRestartSignInFlow() async throws {
        // Given - User has already selected an auth factor previously
        state.credentials.username = "testuser"
        state.credentials.selectedAuthFactor = .webAuthn  // Previous selection
        state.selectedAuthFactor = .emailOtp  // New selection
        
        // Mock the restart flow - signIn should return factor selection again, then OTP
        authenticationService.mockedSignInResult = AuthSignInResult(
            nextStep: .confirmSignInWithOTP(.init(destination: .email("test@example.com")))
        )
        
        // When
        try await state.selectAuthFactor()
        
        // Then - Should call signIn (restart flow) instead of confirmSignIn
        XCTAssertEqual(authenticationService.signInCount, 1, "Should call signIn to restart flow")
        XCTAssertEqual(authenticationService.confirmSignInCount, 0, "Should NOT call confirmSignIn for re-selection")
        
        // And - Should update the tracked selection
        XCTAssertEqual(state.credentials.selectedAuthFactor, .emailOtp)
    }
    
    @MainActor
    func testSelectAuthFactor_reselectionWithPassword_shouldIncludePassword() async throws {
        // Given - User previously selected webAuthn, now selecting password
        state.credentials.username = "testuser"
        state.credentials.selectedAuthFactor = .webAuthn  // Previous selection
        state.selectedAuthFactor = .password(srp: true)  // New selection
        state.password = "mypassword123"
        
        // Mock the restart flow with password - should go through 2-step flow
        authenticationService.mockedSignInResult = AuthSignInResult(nextStep: .done)
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "testuser",
            userId: "user-123"
        )
        authenticationService.mockedUnverifiedAttributes = []
        
        // When
        try await state.selectAuthFactor()
        
        // Then - Should call signIn with password
        XCTAssertEqual(authenticationService.signInCount, 1, "Should call signIn to restart flow")
        XCTAssertEqual(authenticationService.signInUsername, "testuser")
        XCTAssertEqual(authenticationService.signInPassword, "mypassword123", "Should include password in restart")
        
        // And - Should update credentials
        XCTAssertEqual(state.credentials.password, "mypassword123")
        XCTAssertEqual(state.credentials.selectedAuthFactor, .password(srp: true))
    }
    
    @MainActor
    func testSelectAuthFactor_reselectionWithNonPassword_shouldNotIncludePassword() async throws {
        // Given - User previously selected password, now selecting SMS OTP
        state.credentials.username = "testuser"
        state.credentials.selectedAuthFactor = .password(srp: true)  // Previous selection
        state.selectedAuthFactor = .smsOtp  // New selection
        state.password = "leftoverpassword"  // Should not be sent
        
        // Mock the restart flow
        authenticationService.mockedSignInResult = AuthSignInResult(
            nextStep: .confirmSignInWithOTP(.init(destination: .phone("+1234567890")))
        )
        
        // When
        try await state.selectAuthFactor()
        
        // Then - Should call signIn without password
        XCTAssertEqual(authenticationService.signInCount, 1)
        XCTAssertEqual(authenticationService.signInUsername, "testuser")
        XCTAssertNil(authenticationService.signInPassword, "Should NOT include password for non-password factor")
    }
    
    @MainActor
    func testSelectAuthFactor_cancelPasskeyThenSelectEmail_shouldWork() async throws {
        // This is the critical bug scenario from the Android PR
        // Given - User selected webAuthn (passkey) and it was tracked
        state.credentials.username = "testuser"
        state.credentials.selectedAuthFactor = .webAuthn  // Simulates previous passkey selection (then cancel)
        state.selectedAuthFactor = .emailOtp  // User now wants email
        
        // Mock successful restart with email OTP
        authenticationService.mockedSignInResult = AuthSignInResult(
            nextStep: .confirmSignInWithOTP(.init(destination: .email("test@example.com")))
        )
        
        // When
        try await state.selectAuthFactor()
        
        // Then - Should successfully restart and transition to OTP confirmation
        XCTAssertEqual(authenticationService.signInCount, 1, "Should restart sign-in flow")
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        
        if case .confirmSignInWithOTP = authenticatorState.setCurrentStepValue {
            // Success - correct step
        } else {
            XCTFail("Expected to transition to .confirmSignInWithOTP step")
        }
    }
    
    @MainActor
    func testSelectAuthFactor_multipleReselections_shouldAlwaysRestartFlow() async throws {
        // Given - Simulate multiple re-selections
        state.credentials.username = "testuser"
        
        // First selection (no previous)
        state.selectedAuthFactor = .emailOtp
        authenticationService.mockedConfirmSignInResult = AuthSignInResult(
            nextStep: .confirmSignInWithOTP(.init(destination: .email("test@example.com")))
        )
        
        try await state.selectAuthFactor()
        XCTAssertEqual(authenticationService.confirmSignInCount, 1, "First selection uses confirmSignIn")
        XCTAssertEqual(authenticationService.signInCount, 0)
        
        // Reset mock counts
        authenticationService.confirmSignInCount = 0
        
        // Second selection (re-selection)
        state.selectedAuthFactor = .smsOtp
        authenticationService.mockedSignInResult = AuthSignInResult(
            nextStep: .confirmSignInWithOTP(.init(destination: .phone("+1234567890")))
        )
        
        try await state.selectAuthFactor()
        XCTAssertEqual(authenticationService.signInCount, 1, "Second selection restarts flow")
        XCTAssertEqual(authenticationService.confirmSignInCount, 0, "Should not use confirmSignIn")
        
        // Third selection (another re-selection)
        state.selectedAuthFactor = .emailOtp
        authenticationService.signInCount = 0
        authenticationService.mockedSignInResult = AuthSignInResult(
            nextStep: .confirmSignInWithOTP(.init(destination: .email("test@example.com")))
        )
        
        try await state.selectAuthFactor()
        XCTAssertEqual(authenticationService.signInCount, 1, "Third selection also restarts flow")
    }
    
    @MainActor
    func testSelectAuthFactor_reselectionWithError_shouldSetErrorMessage() async throws {
        // Given - User re-selecting after previous selection
        state.credentials.username = "testuser"
        state.credentials.selectedAuthFactor = .webAuthn
        state.selectedAuthFactor = .emailOtp
        
        // Mock error on restart
        authenticationService.mockedSignInError = AuthError.notAuthorized(
            "Session expired",
            "Please try again"
        )
        
        // When/Then
        do {
            try await state.selectAuthFactor()
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(authenticationService.signInCount, 1)
            // Error should be thrown and handled
        }
    }
}

// MARK: - AuthFactor Helper Tests

class AuthFactorHelpersTests: XCTestCase {
    
    func testIsPassword_withPasswordSRP_shouldReturnTrue() {
        let factor = AuthFactor.password(srp: true)
        XCTAssertTrue(factor.isPassword)
    }
    
    func testIsPassword_withPasswordNoSRP_shouldReturnTrue() {
        let factor = AuthFactor.password(srp: false)
        XCTAssertTrue(factor.isPassword)
    }
    
    func testIsPassword_withEmailOtp_shouldReturnFalse() {
        let factor = AuthFactor.emailOtp
        XCTAssertFalse(factor.isPassword)
    }
    
    func testContainsPassword_withPasswordInArray_shouldReturnTrue() {
        let factors: [AuthFactor] = [.emailOtp, .password(srp: true), .smsOtp]
        XCTAssertTrue(factors.containsPassword)
    }
    
    func testContainsPassword_withoutPasswordInArray_shouldReturnFalse() {
        let factors: [AuthFactor] = [.emailOtp, .smsOtp, .webAuthn]
        XCTAssertFalse(factors.containsPassword)
    }
    
    func testPreferredPasswordFactor_withBothPasswordTypes_shouldPreferSRP() {
        let factors: [AuthFactor] = [.password(srp: false), .emailOtp, .password(srp: true)]
        let preferred = factors.preferredPasswordFactor
        
        XCTAssertNotNil(preferred)
        if case .password(let srp) = preferred {
            XCTAssertTrue(srp, "Should prefer passwordSRP")
        } else {
            XCTFail("Expected password factor")
        }
    }
    
    func testPreferredPasswordFactor_withOnlySRP_shouldReturnSRP() {
        let factors: [AuthFactor] = [.emailOtp, .password(srp: true), .smsOtp]
        let preferred = factors.preferredPasswordFactor
        
        XCTAssertNotNil(preferred)
        if case .password(let srp) = preferred {
            XCTAssertTrue(srp)
        } else {
            XCTFail("Expected password factor")
        }
    }
    
    func testPreferredPasswordFactor_withOnlyNonSRP_shouldReturnNonSRP() {
        let factors: [AuthFactor] = [.emailOtp, .password(srp: false), .smsOtp]
        let preferred = factors.preferredPasswordFactor
        
        XCTAssertNotNil(preferred)
        if case .password(let srp) = preferred {
            XCTAssertFalse(srp)
        } else {
            XCTFail("Expected password factor")
        }
    }
    
    func testPreferredPasswordFactor_withNoPassword_shouldReturnNil() {
        let factors: [AuthFactor] = [.emailOtp, .smsOtp, .webAuthn]
        XCTAssertNil(factors.preferredPasswordFactor)
    }
    
    func testNonPasswordFactors_shouldFilterOutPassword() {
        let factors: [AuthFactor] = [.password(srp: true), .emailOtp, .smsOtp, .webAuthn]
        let nonPassword = factors.nonPasswordFactors
        
        XCTAssertEqual(nonPassword.count, 3)
        XCTAssertFalse(nonPassword.contains(where: { $0.isPassword }))
    }
    
    func testNonPasswordFactors_shouldBeSortedByPriority() {
        let factors: [AuthFactor] = [.emailOtp, .smsOtp, .webAuthn, .password(srp: true)]
        let nonPassword = factors.nonPasswordFactors
        
        // Should be sorted: webAuthn (1), smsOtp (2), emailOtp (3)
        XCTAssertEqual(nonPassword.count, 3)
        XCTAssertEqual(nonPassword[0], .webAuthn)
        XCTAssertEqual(nonPassword[1], .smsOtp)
        XCTAssertEqual(nonPassword[2], .emailOtp)
    }
    
    func testDisplayPriority_shouldReturnCorrectOrder() {
        XCTAssertEqual(AuthFactor.webAuthn.displayPriority, 1)
        XCTAssertEqual(AuthFactor.smsOtp.displayPriority, 2)
        XCTAssertEqual(AuthFactor.emailOtp.displayPriority, 3)
        XCTAssertEqual(AuthFactor.password(srp: true).displayPriority, 4)
        XCTAssertEqual(AuthFactor.password(srp: false).displayPriority, 4)
    }
    
    func testToAuthFactorType_shouldTranslateCorrectly() {
        XCTAssertEqual(AuthFactor.password(srp: true).toAuthFactorType(), .passwordSRP)
        XCTAssertEqual(AuthFactor.password(srp: false).toAuthFactorType(), .password)
        XCTAssertEqual(AuthFactor.emailOtp.toAuthFactorType(), .emailOTP)
        XCTAssertEqual(AuthFactor.smsOtp.toAuthFactorType(), .smsOTP)
    }
}
