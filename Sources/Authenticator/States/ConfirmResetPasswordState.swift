//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

/// The state observed by the Confirm Reset Password content view, representing the ``Authenticator`` is in the ``AuthenticatorStep/confirmResetPassword`` step.
public class ConfirmResetPasswordState: AuthenticatorBaseState {
    /// The confirmation code provided by the user
    @Published public var confirmationCode: String = ""

    /// The new password provided by the user
    @Published public var newPassword: String = ""

    /// The new password confirmation provided by the user
    @Published public var confirmPassword: String = ""

    /// The `Amplify.AuthCodeDeliveryDetails` associated with this state. If the Authenticator is not in the `.confirmResetPassword` step, it returns `nil`
    public var deliveryDetails: AuthCodeDeliveryDetails? {
        guard case .confirmResetPassword(let deliveryDetails) = authenticatorState.step else {
            return nil
        }

        return deliveryDetails
    }

    /// Attempts to confirm the new password using the provided values.
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func confirmResetPassword() async throws {
        setBusy(true)

        do {
            log.verbose("Attempting to confirm Password Reset")
            try await authenticationService.confirmResetPassword(
                for: credentials.username,
                with: newPassword,
                confirmationCode: confirmationCode,
                options: nil
            )

            let nextStep = await nextStep()
            setBusy(false)
            authenticatorState.setCurrentStep(nextStep)
        } catch {
            log.error("Confirm Reset Password failed")
            let authenticationError = self.error(for: error)
            setMessage(authenticationError)
            throw authenticationError
        }
    }

    private func nextStep() async -> Step {
        do {
            let result = try await authenticationService.signIn(
                username: credentials.username,
                password: newPassword,
                options: nil
            )

            return try await nextStep(for: result)
        } catch {
            log.error("Unable to Sign In after confirming password reset")
            log.error(error: error)
            return .signIn
        }
    }
}

extension ConfirmResetPasswordState {
    enum Field: Int, Hashable, CaseIterable {
        case confirmationCode
        case newPassword
        case newPasswordConfirmation
    }
}

