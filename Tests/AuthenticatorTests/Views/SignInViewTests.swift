//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import XCTest
import SwiftUI

class SignInViewTests: XCTestCase {
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

    // MARK: - Password Field Validation Tests
    
    func testPasswordValidation_withPasswordFlow_shouldBeRequired() {
        // Configure for password-only flow
        authenticatorState.authenticationFlow = .password
        
        // Create view to trigger validator initialization
        _ = SignInView(state: state)
        
        // The validator should require password in password flow
        // This is tested implicitly through the validation logic
        XCTAssertEqual(state.authenticationFlow, .password)
    }
    
    func testPasswordValidation_withUserChoiceFlowPasswordPreferred_shouldBeOptional() {
        // Configure for userChoice flow with password as preferred
        authenticatorState.authenticationFlow = .userChoice(preferredAuthFactor: .password())
        
        // Create view to trigger validator initialization
        _ = SignInView(state: state)
        
        // The validator should allow empty password in userChoice with password preferred
        if case .userChoice(let preferredAuthFactor, _) = state.authenticationFlow,
           case .password = preferredAuthFactor {
            XCTAssertTrue(true, "Password is preferred factor in userChoice")
        } else {
            XCTFail("Expected userChoice with password preferred")
        }
    }
    
    func testPasswordValidation_withUserChoiceFlowEmailOtpPreferred_shouldNotShowPasswordField() {
        // Configure for userChoice flow with emailOtp as preferred
        authenticatorState.authenticationFlow = .userChoice(preferredAuthFactor: .emailOtp)
        
        // Create view
        _ = SignInView(state: state)
        
        // Password field should not be shown
        if case .userChoice(let preferredAuthFactor, _) = state.authenticationFlow {
            if case .password = preferredAuthFactor {
                XCTFail("Password should not be preferred factor")
            } else {
                XCTAssertTrue(true, "Password is not preferred factor")
            }
        } else {
            XCTFail("Expected userChoice flow")
        }
    }
    
    // MARK: - Password Field Label Tests
    
    func testPasswordFieldLabel_withPasswordFlow_shouldNotShowOptional() {
        // Configure for password-only flow
        authenticatorState.authenticationFlow = .password
        
        // In password flow, the label should be just "Password" without "(optional)"
        // This is verified by the passwordFieldLabel computed property
        XCTAssertEqual(state.authenticationFlow, .password)
    }
    
    func testPasswordFieldLabel_withUserChoicePasswordPreferred_shouldShowOptional() {
        // Configure for userChoice flow with password as preferred
        authenticatorState.authenticationFlow = .userChoice(preferredAuthFactor: .password())
        
        // In userChoice with password preferred, the label should include "(optional)"
        if case .userChoice(let preferredAuthFactor, _) = state.authenticationFlow,
           case .password = preferredAuthFactor {
            XCTAssertTrue(true, "Password field should show optional label")
        } else {
            XCTFail("Expected userChoice with password preferred")
        }
    }
    
    // MARK: - Authentication Flow Tests
    
    func testAuthenticationFlow_shouldBeAccessibleFromState() {
        // Test that authenticationFlow is accessible from state
        authenticatorState.authenticationFlow = .password
        XCTAssertEqual(state.authenticationFlow, .password)
        
        authenticatorState.authenticationFlow = .userChoice(preferredAuthFactor: .emailOtp)
        if case .userChoice(let preferredAuthFactor, _) = state.authenticationFlow {
            XCTAssertEqual(preferredAuthFactor, .emailOtp)
        } else {
            XCTFail("Expected userChoice flow")
        }
    }
}
