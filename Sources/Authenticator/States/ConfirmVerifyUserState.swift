//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// The state observed by the Confirm Verify User content view, representing the ``Authenticator`` is in the ``AuthenticatorStep/confirmVerifyUser`` step.
public class ConfirmVerifyUserState: AuthenticatorBaseState {
    /// The confirmation code provided by the user
    @Published public var confirmationCode: String = ""

    /// The `Amplify.AuthUserAttributeKey` associated with this state. If the Authenticator is not in the `.confirmVerifyUser` step, it returns `nil`
    public var userAttributeKey: AuthUserAttributeKey? {
        guard case .confirmVerifyUser(let attribute, _) = authenticatorState.step else {
            return nil
        }

        return attribute
    }

    /// The `Amplify.AuthCodeDeliveryDetails` associated with this state. If the Authenticator is not in the `.confirmVerifyUser` step, it returns `nil`
    public var deliveryDetails: AuthCodeDeliveryDetails? {
        guard case .confirmVerifyUser(_, let deliveryDetails) = authenticatorState.step else {
            return nil
        }

        return deliveryDetails
    }

    /// Attempts to verify the associated ``userAttributeKey`` using the provided confirmation code
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// `Amplify.AuthenticatorBaseState/isBusy` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func confirmVerifyUser() async throws {
        guard let userAttributeKey = userAttributeKey else {
            return
        }
        setBusy(true)

        do {
            log.verbose("Attempting to confirm attribute \(userAttributeKey)")
            try await authenticationService.confirm(
                userAttribute: userAttributeKey,
                confirmationCode: confirmationCode,
                options: nil
            )

            let user = try await authenticationService.getCurrentUser()

            setBusy(false)

            authenticatorState.setCurrentStep(.signedIn(user: user))
        } catch {
            log.error("Unable to confirm user attribute")
            let authenticationError = self.error(for: error)
            setMessage(authenticationError)
            throw authenticationError
        }
    }

    /// Skips the verification of the assocaited ``userAttributeKey`` and attempts to proceed with sign in
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
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
