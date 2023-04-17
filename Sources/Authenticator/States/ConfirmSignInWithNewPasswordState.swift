//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

/// The state observed by the Confirm Sign In with New Password content view, representing the Authenticator is in the `.confirmSignInWithNewPassword` step.
public class ConfirmSignInWithNewPasswordState: AuthenticatorBaseState {
    /// The new password provided by the user
    @Published public var newPassword: String = ""

    /// The new password confirmation provided by the user
    @Published public var confirmPassword: String = ""

    /// Attempts to confirm the user's Sign In with the provided new password
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An ``AuthenticationError`` if the operation fails
    public func confirmSignIn() async throws {
        setBusy(true)

        do {
            log.verbose("Attempting to confirm Sign In")
            let result = try await authenticationService.confirmSignIn(
                challengeResponse: newPassword,
                options: nil
            )

            let nextStep = try await nextStep(for: result)

            setBusy(false)

            authenticatorState.setCurrentStep(nextStep)
        } catch {
            log.error("Confirm Sign In with new password failed")
            let authenticationError = self.error(for: error)
            setMessage(authenticationError)
            throw authenticationError
        }
    }
}

extension ConfirmSignInWithNewPasswordState {
    enum Field: Int, Hashable, CaseIterable {
        case newPassword
        case newPasswordConfirmation
    }
}

