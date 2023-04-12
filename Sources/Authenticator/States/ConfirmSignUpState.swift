//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI
import AWSCognitoAuthPlugin

/// The state observed by the Confirm Sign Up content view, representing the Authenticator is in the `.confirmSignUp` step.
public class ConfirmSignUpState: AuthenticatorBaseState {
    /// The confirmation code provided by the user
    @Published public var confirmationCode: String = ""

    /// The ``AuthCodeDeliveryDetails`` associated with this state. If the Authenticator is not in the `.confirmSignUp` step, it returns `nil`
    public var deliveryDetails: AuthCodeDeliveryDetails? {
        guard case .confirmSignUp(let deliveryDetails) = authenticatorState.step else {
            return nil
        }

        return deliveryDetails
    }

    /// Attempts to confirm the user's Sign Up using the provided confirmation code.
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An ``AuthenticationError`` if the operation fails
    public func confirmSignUp() async throws {
        setBusy(true)

        do {
            log.verbose("Attempting to confirm Sign Up")
            let result = try await authenticationService.confirmSignUp(
                for: credentials.username,
                confirmationCode: confirmationCode,
                options: nil)

            let nextStep = try await nextStep(for: result)
            setBusy(false)
            authenticatorState.setCurrentStep(nextStep)
        } catch {
            log.error("Confirm Sign Up failed")
            let authenticationError = self.error(for: error)
            setMessage(authenticationError)
            throw authenticationError
        }
    }

    /// Attempts to resend the user's Sign Up confirmation code.
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An ``AuthenticationError`` if the operation fails
    public func sendCode() async throws {
        setBusy(true)

        do {
            log.verbose("Attempting to resend the Sign Up code")
            let details = try await authenticationService.resendSignUpCode(
                for: credentials.username,
                options: nil
            )

            setMessage(.info(message: localizedMessage(for: details)))
        } catch {
            log.error("Unable to resend the Sign Up confirmation code")
            let authenticationError = self.error(for: error)
            setMessage(authenticationError)
            throw authenticationError
        }
    }

    var username: String {
        return credentials.username
    }

    var password: String? {
        return credentials.password
    }
}
