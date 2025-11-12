//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// The state observed by the Prompt To Create Passkey content view, representing the ``Authenticator`` is in the ``AuthenticatorStep/promptToCreatePasskey`` step.
public class PromptToCreatePasskeyState: AuthenticatorBaseState {
    
    override init(credentials: Credentials) {
        super.init(credentials: credentials)
    }
    
    init(authenticatorState: AuthenticatorStateProtocol) {
        super.init(authenticatorState: authenticatorState,
                   credentials: Credentials())
    }
    
    /// Attempts to create a passkey for the user
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func createPasskey() async throws {
        setBusy(true)
        
        do {
            log.verbose("Attempting to create passkey")
            
            // Call Amplify WebAuthn API to associate a passkey credential
            if #available(iOS 17.4, macOS 13.5, visionOS 1.0, *) {
                try await authenticationService.associateWebAuthnCredential(
                    presentationAnchor: nil,
                    options: nil
                )
            } else {
                throw AuthError.configuration(
                    "WebAuthn is not supported on this platform",
                    "WebAuthn requires iOS 17.4+, macOS 13.5+, or visionOS 1.0+",
                    nil
                )
            }
            
            log.verbose("Passkey created successfully")
            setBusy(false)
            authenticatorState.setCurrentStep(.passkeyCreated)
        } catch {
            log.error("Passkey creation failed: \(error)")
            setBusy(false)
            let authenticationError = self.error(for: error)
            setMessage(authenticationError)
            throw authenticationError
        }
    }
    
    /// Skips passkey creation and continues with the authentication flow
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func skip() async throws {
        setBusy(true)
        
        do {
            log.verbose("Skipping passkey creation")
            // Use post-passkey logic (attribute verification and sign-in)
            let nextStep = try await nextStepAfterPasskeyFlow()
            
            setBusy(false)
            authenticatorState.setCurrentStep(nextStep)
        } catch {
            log.error("Skip passkey creation failed")
            setBusy(false)
            let authenticationError = self.error(for: error)
            setMessage(authenticationError)
            throw authenticationError
        }
    }
}
