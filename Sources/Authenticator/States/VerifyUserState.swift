//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// The state observed by the Verify User content view, representing the Authenticator is in the `.verifyUser` step.
public class VerifyUserState: AuthenticatorBaseState {
    /// The `AuthUserAttributeKey` to be verified selected by the user
    @Published public var selectedField: AuthUserAttributeKey?

    /// An array of the unverified ``AuthUserAttributeKey`` that are associated with this state. If the Authenticator is not in the `.verifyUser` step, it returns an empty array.
    public var unverifiedFields: [AuthUserAttributeKey] {
        guard case .verifyUser(let attributes) = authenticatorState.step else {
            return []
        }

        return attributes
    }

    /// Attempts to request a verification for the attribute selected by the user
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An ``AuthenticationError`` if the operation fails
    public func verifyUser() async throws {
        guard let key = selectedField else {
            return
        }

        setBusy(true)

        do {
            log.verbose("Attempting to verify user attribute \(key)")
            let result = try await authenticationService.resendConfirmationCode(
                forUserAttributeKey: key,
                options: nil
            )
            setBusy(false)
            authenticatorState.setCurrentStep(
                .confirmVerifyUser(attribute: key, deliveryDetails: result)
            )
        } catch {
            log.error("Unable to send confirmation code for user attribute")
            let authenticationError = self.error(for: error)
            setMessage(authenticationError)
            throw authenticationError
        }
    }

    /// Skips the verification of the assocaited ``userAttributeKey`` and attempts to proceed with sign in
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An ``AuthenticationError`` if the operation fails
    public func skip() async throws {
        setBusy(true)

        do {
            log.verbose("Skipping user verification")
            let user = try await authenticatorState.authenticationService.getCurrentUser()
            authenticatorState.setCurrentStep(.signedIn(user: user))
            setBusy(false)
        } catch {
            log.error("Unable to get the current user after skipping verification")
            log.error(error: error)
            setBusy(false)
            // Go back to sign in
            authenticatorState.setCurrentStep(.signIn)
        }
    }
}
