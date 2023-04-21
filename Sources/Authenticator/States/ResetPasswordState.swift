//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// The state observed by the Reset Password content view, representing the ``Authenticator`` is in the ``AuthenticatorStep/resetPassword`` step.
public class ResetPasswordState: AuthenticatorBaseState {
    /// The username provided by the user
    @Published public var username: String = "" {
        didSet {
            credentials.username = username
        }
    }

    /// Attempts to request a password reset for the provided username.
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func resetPassword() async throws {
        setBusy(true)
        do {
            log.verbose("Attempting to reset password")
            let result = try await authenticationService.resetPassword(
                for: username,
                options: nil
            )
            setBusy(false)

            switch result.nextStep {
            case .confirmResetPasswordWithCode(let details, _):
                authenticatorState.setCurrentStep(.confirmResetPassword(deliveryDetails: details))
            case .done:
                // This should not happen, go back to Sign In screen
                log.warn("Received done next step after initiating a reset password. This is unexpected")
                authenticatorState.setCurrentStep(.signIn)
            }
        } catch {
            log.error("Unable to initialize a password reset")
            let authenticationError = self.error(for: error)
            setMessage(authenticationError)
            throw authenticationError
        }
    }

    /// Manually moves the Authenticator to a different initial step
    /// - Parameter initialStep: The desired ``AuthenticatorInitialStep``
    public func move(to initialStep: AuthenticatorInitialStep) {
        authenticatorState.move(to: initialStep)
    }
}
