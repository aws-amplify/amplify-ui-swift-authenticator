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
    ///
    /// If the user has already selected an auth factor previously (tracked via `credentials.selectedAuthFactor`),
    /// this method will restart the sign-in flow with the new factor as the preferred first factor.
    /// This is necessary because Cognito doesn't allow changing the auth factor selection once made.
    ///
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
            
            // Check if user has already selected an auth factor previously
            // If so, we need to restart the sign-in flow instead of calling confirmSignIn
            let flowRestartRequired = credentials.selectedAuthFactor != nil
            
            // Update password in credentials if password factor is selected
            if factor.isPassword {
                credentials.password = password
            }
            
            // Track the selected auth factor
            credentials.selectedAuthFactor = factor
            
            let result: AuthSignInResult
            
            if flowRestartRequired {
                // User has already selected an auth factor before
                // Restart sign-in flow with the new factor as preferred
                log.verbose("Restarting sign-in flow with preferred factor: \(factor)")
                result = try await restartSignInWithPreferredFactor(factor)
            } else {
                // First-time selection - use confirmSignIn as normal
                result = try await confirmSignInWithFactor(factor)
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
    
    /// Confirms sign-in with the selected auth factor (first-time selection)
    /// - Parameter factor: The auth factor to use
    /// - Returns: The `AuthSignInResult` from the confirmation
    private func confirmSignInWithFactor(_ factor: AuthFactor) async throws -> AuthSignInResult {
        switch factor {
        case .password:
            // Password requires 2-step flow, use dedicated method
            // Step 1: Select password factor → confirmSignIn("PASSWORD") → .confirmSignInWithPassword
            // Step 2: Send password → confirmSignIn("Pass@123") → .done
            return try await signInWithPassword()
            
        case .emailOtp, .smsOtp:
            // Select the auth factor and move to appropriate next step
            // Use the AuthFactor extension to get the challenge response
            let challengeResponse = factor.toAuthFactorType().challengeResponse
            
            return try await authenticationService.confirmSignIn(
                challengeResponse: challengeResponse,
                options: nil
            )
            
        case .webAuthn:
            // WebAuthn sign-in - Amplify handles the native UI
            #if os(iOS) || os(macOS) || os(visionOS)
            guard #available(iOS 17.4, macOS 13.5, visionOS 1.0, *) else {
                log.error("WebAuthn requires iOS 17.4+, macOS 13.5+, or visionOS 1.0+")
                throw AuthError.unknown("Passkey is not available", nil)
            }
            
            log.verbose("Initiating WebAuthn sign-in")
            
            // Select WebAuthn as the auth factor
            let challengeResponse = factor.toAuthFactorType().challengeResponse
            
            return try await authenticationService.confirmSignIn(
                challengeResponse: challengeResponse,
                options: nil
            )
            #else
            log.error("WebAuthn is not available on this platform")
            throw AuthError.unknown("Passkey is not available", nil)
            #endif
        }
    }
    
    /// Restarts the sign-in flow with the specified factor as the preferred first factor.
    /// This is used when the user changes their auth factor selection after already selecting one.
    /// - Parameter factor: The auth factor to use as the preferred first factor
    /// - Returns: The `AuthSignInResult` from the sign-in attempt
    private func restartSignInWithPreferredFactor(_ factor: AuthFactor) async throws -> AuthSignInResult {
        let options = AuthSignInRequest.Options(
            pluginOptions: AWSAuthSignInOptions(
                authFlowType: .userAuth(preferredFirstFactor: factor.toAuthFactorType())
            )
        )
        
        return try await authenticationService.signIn(
            username: credentials.username,
            password: factor.isPassword ? credentials.password : nil,
            options: options
        )
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
