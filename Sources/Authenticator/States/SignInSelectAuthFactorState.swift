//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

/// The state observed by the Sign In Select Auth Factor content view, representing the ``Authenticator`` is in the ``AuthenticatorStep/signInSelectAuthFactor`` step.
public class SignInSelectAuthFactorState: AuthenticatorBaseState {
    /// The password provided by the user (for password-based auth factors)
    @Published public var password: String = "" {
        didSet {
            credentials.password = password
        }
    }
    
    /// The selected authentication factor
    @Published public var selectedAuthFactor: AuthFactor?
    
    /// The username for this sign-in attempt
    public var username: String {
        return credentials.username
    }
    
    /// The available authentication factors for this user
    public var availableAuthFactors: [AuthFactor]
    
    init(credentials: Credentials, availableAuthFactors: [AuthFactor]) {
        self.availableAuthFactors = availableAuthFactors
        super.init(credentials: credentials)
    }
    
    /// Attempts to sign in using the selected authentication factor
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func selectAuthFactor() async throws {
        guard let factor = selectedAuthFactor else {
            log.verbose("No auth factor selected")
            setBusy(false)
            return
        }
        
        setBusy(true)
        
        do {
            log.verbose("Selecting auth factor: \(factor)")
            
            let result: AuthSignInResult
            
            switch factor {
            case .password:
                // Password requires 2-step flow, use dedicated method
                // Step 1: Select password factor → confirmSignIn("PASSWORD") → .confirmSignInWithPassword
                // Step 2: Send password → confirmSignIn("Pass@123") → .done
                result = try await signInWithPassword()
                
            case .emailOtp, .smsOtp:
                // Select the auth factor and move to appropriate next step
                // Use the AuthFactor extension to get the challenge response
                let challengeResponse = factor.toAuthFactorType().challengeResponse
                
                result = try await authenticationService.confirmSignIn(
                    challengeResponse: challengeResponse,
                    options: nil
                )
                
            case .webAuthn:
                // TODO: Implement WebAuthn sign-in
                // This will show the native WebAuthn UI
                setBusy(false)
                log.verbose("WebAuthn sign-in not yet implemented")
                setMessage(.error(message: "WebAuthn sign-in is not yet implemented"))
                return
            }
            
            let nextStep = try await nextStep(for: result)
            setBusy(false)
            authenticatorState.setCurrentStep(nextStep)
        } catch {
            log.error("Unable to select auth factor")
            let authenticationError = self.error(for: error)
            setMessage(authenticationError)
            throw authenticationError
        }
    }
    
    /// Signs in with password using the multi-step flow
    ///
    /// Password flow:
    /// 1. Select password factor → confirmSignIn("PASSWORD") → returns .confirmSignInWithPassword
    /// 2. Send actual password → confirmSignIn("Pass@123") → returns .done
    ///
    /// This method handles both steps and returns the final result.
    /// - Returns: The final `AuthSignInResult` after completing both steps
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    private func signInWithPassword() async throws -> AuthSignInResult {
        guard let passwordFactor = availableAuthFactors.preferredPasswordFactor else {
            log.verbose("Password auth factor not available")
            throw AuthError.unknown("Password auth factor not available", nil)
        }
        
        log.verbose("Starting password sign-in flow")
        
        // Step 1: Select password as the auth factor
        let factorChallengeResponse = passwordFactor.toAuthFactorType().challengeResponse
        let factorResult = try await authenticationService.confirmSignIn(
            challengeResponse: factorChallengeResponse,
            options: nil
        )
        
        // Check if we got .confirmSignInWithPassword as expected
        guard case .confirmSignInWithPassword = factorResult.nextStep else {
            // Unexpected step - password factor selection should return .confirmSignInWithPassword
            log.error("Unexpected next step after password factor selection: \(factorResult.nextStep)")
            throw AuthError.unknown("Expected .confirmSignInWithPassword but got \(factorResult.nextStep)", nil)
        }
        
        log.verbose("Password factor selected, now sending password")
        
        // Step 2: Send the actual password
        let passwordResult = try await authenticationService.confirmSignIn(
            challengeResponse: password,
            options: nil
        )
        
        return passwordResult
    }
    
    /// Manually moves the Authenticator to a different initial step
    /// - Parameter initialStep: The desired ``AuthenticatorInitialStep``
    public func move(to initialStep: AuthenticatorInitialStep) {
        authenticatorState.move(to: initialStep)
    }
}

extension SignInSelectAuthFactorState {
    enum Field: Int, Hashable, CaseIterable {
        case password
        case authFactor
    }
}
