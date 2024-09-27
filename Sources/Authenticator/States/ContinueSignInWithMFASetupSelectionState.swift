//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

/// The state observed by the Continue Sign In With MFA Setup Selection content views, representing the ``Authenticator`` is in the ``AuthenticatorStep/continueSignInWithMFASetupSelection`` step.
public class ContinueSignInWithMFASetupSelectionState: AuthenticatorBaseState {

    /// The MFA type selected by the user
    @Published public var selectedMFATypeToSetup: MFAType?

    init(authenticatorState: AuthenticatorStateProtocol,
         allowedMFATypes: AllowedMFATypes) {
        self.allowedMFATypes = allowedMFATypes
        super.init(authenticatorState: authenticatorState,
                   credentials: Credentials())
    }

    /// The `Amplify.AllowedMFATypes` associated with this state.
    public let allowedMFATypes: AllowedMFATypes

    /// Attempts to continue the user's sign in using the provided MFA type to setup.
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func continueSignIn() async throws {
        guard let selectedMFATypeToSetup = selectedMFATypeToSetup else {
            log.error("MFA type not selected")
            return
        }

        setBusy(true)
        do {
            log.verbose("Attempting to continue Sign In with selected MFA type to setup")
            let result = try await authenticationService.confirmSignIn(
                challengeResponse: selectedMFATypeToSetup.challengeResponse,
                options: nil
            )
            let nextStep = try await nextStep(for: result)

            setBusy(false)

            authenticatorState.setCurrentStep(nextStep)
        } catch {
            log.error("Continue Sign In with MFA Setup Selection failed")
            let authenticationError = self.error(for: error)
            setMessage(authenticationError)
            throw authenticationError
        }
    }
}
