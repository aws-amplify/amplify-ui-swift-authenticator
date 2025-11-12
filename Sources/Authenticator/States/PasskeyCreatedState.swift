//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// The state observed by the Passkey Created content view, representing the ``Authenticator`` is in the ``AuthenticatorStep/passkeyCreated`` step.
public class PasskeyCreatedState: AuthenticatorBaseState {
    
    /// The list of WebAuthn credentials (passkeys) for the user
    @Published public var passkeyCredentials: [AuthWebAuthnCredential] = []
    
    override init(credentials: Credentials) {
        super.init(credentials: credentials)
    }
    
    init(authenticatorState: AuthenticatorStateProtocol) {
        super.init(authenticatorState: authenticatorState,
                   credentials: Credentials())
    }
    
    /// Fetches the list of passkey credentials for the user
    public func fetchPasskeyCredentials() async {
        do {
            log.verbose("Fetching passkey credentials")
            
            if #available(iOS 17.4, macOS 13.5, visionOS 1.0, *) {
                let result = try await authenticationService.listWebAuthnCredentials(options: nil)
                
                await MainActor.run {
                    self.passkeyCredentials = result.credentials
                }
                log.verbose("Fetched \(result.credentials.count) passkey credentials")
            } else {
                log.error("WebAuthn is not supported on this platform (requires iOS 17.4+, macOS 13.5+, or visionOS 1.0+)")
            }
        } catch {
            log.error("Failed to fetch passkey credentials: \(error)")
            // Don't throw - just log the error, credentials list will remain empty
        }
    }
    
    /// Continues the authentication flow after passkey creation
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func `continue`() async throws {
        setBusy(true)
        
        do {
            log.verbose("Continuing after passkey creation")
            // Use post-passkey logic (attribute verification and sign-in)
            let nextStep = try await nextStepAfterPasskeyFlow()
            
            setBusy(false)
            authenticatorState.setCurrentStep(nextStep)
        } catch {
            log.error("Continue after passkey creation failed")
            setBusy(false)
            let authenticationError = self.error(for: error)
            setMessage(authenticationError)
            throw authenticationError
        }
    }
}
