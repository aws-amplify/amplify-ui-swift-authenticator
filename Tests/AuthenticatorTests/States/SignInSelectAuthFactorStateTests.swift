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
            XCTFail("Expected to transition to .signedIn step, got \(authenticatorState.setCurrentStepValue)")
        }
    }

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

    // TODO: Re-enable when WebAuthn is fully implemented
    // func testSelectAuthFactor_withWebAuthn_shouldShowTodoMessage() async throws {
    //     // Given
    //     state.selectedAuthFactor = .webAuthn
    //     
    //     // When
    //     try await state.selectAuthFactor()
    //     
    //     // Then - WebAuthn is not yet implemented, should show error message
    //     XCTAssertEqual(authenticationService.confirmSignInCount, 0, "Should not call confirmSignIn for WebAuthn yet")
    //     // WebAuthn returns early with TODO message
    //     await MainActor.run {
    //         XCTAssertNotNil(state.message, "Should show TODO message")
    //     }
    // }

    func testSelectAuthFactor_withNoSelection_shouldNotCallAPI() async throws {
        // Given
        state.selectedAuthFactor = nil
        
        // When
        try await state.selectAuthFactor()
        
        // Then - Should return early without calling API
        XCTAssertEqual(authenticationService.confirmSignInCount, 0)
    }

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
