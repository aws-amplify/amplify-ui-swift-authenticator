//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

/// The state observed by the Confirm Sign In with Custom Challenge and Confirm Sign In with MFA Code content views,
/// representing the Authenticator is in either the `.confirmSignInWithCustomChallenge` or the `.confirmSignInWithMFACode` step accordingly.
public class ConfirmSignInWithCodeState: AuthenticatorBaseState {
    /// The confirmation code provided by the user
    @Published public var confirmationCode: String = ""

    /// The ``AuthCodeDeliveryDetails`` associated with this state. If the Authenticator is not in the `.confirmSignInWithMFACode` step, it returns `nil`
    public var deliveryDetails: AuthCodeDeliveryDetails? {
        guard case .confirmSignInWithMFACode(let deliveryDetails) = authenticatorState.step else {
            return nil
        }

        return deliveryDetails
    }

    /// Attempts to confirm the user's sign in using the provided confirmation code.
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An ``AuthenticationError`` if the operation fails
    public func confirmSignIn() async throws {
        setBusy(true)

        do {
            log.verbose("Attempting to confirm Sign Up")
            let result = try await authenticationService.confirmSignIn(
                challengeResponse: confirmationCode,
                options: nil
            )
            let nextStep = try await nextStep(for: result)

            setBusy(false)

            authenticatorState.setCurrentStep(nextStep)
        } catch {
            log.error("Confirm Sign In with Code failed")
            let authenticationError = self.error(for: error)
            setMessage(authenticationError)
            throw authenticationError
        }
    }
}
