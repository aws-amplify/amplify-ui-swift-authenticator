//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

/// The state observed by the Continue Sign In With MFA Selection content views, representing the ``Authenticator`` is in  ``AuthenticatorStep/continueSignInWithMFASelection``  step.
public class ContinueSignInWithMFASelectionState: AuthenticatorBaseState {
    /// The MFA selection  provided by the user
    @Published public var selectedMFAType: MFAType?

    /// The `Amplify.AllowedMFATypes` associated with this state. If the Authenticator is not in the `.continueSignInWithMFASelection` step, it returns `empty` result
    public var allowedMFATypes: AllowedMFATypes {
        guard case .continueSignInWithMFASelection(let allowedMFATypes) = authenticatorState.step else {
            return []
        }

        return allowedMFATypes
    }

    /// Attempts to confirm the user's sign in using the provided confirmation code.
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func confirmSignIn() async throws {
        setBusy(true)

        guard let selectedMFAType = selectedMFAType else {
            log.error("MFA type not selected")
            return
        }

        do {
            log.verbose("Attempting to confirm Sign Up")
            let result = try await authenticationService.confirmSignIn(
                challengeResponse: selectedMFAType.challengeResponse,
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
