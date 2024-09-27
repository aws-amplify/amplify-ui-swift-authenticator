//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

/// The state observed by the Continue Sign In with Email MFA Setup Challenge, representing the ``Authenticator`` is in the ``AuthenticatorStep/continueSignInWithEmailMFASetup`` step.
public class ContinueSignInWithEmailMFASetupState: AuthenticatorBaseState {
    /// The email provided by the user
    @Published public var email: String = ""

    override init(credentials: Credentials) {
        super.init(credentials: credentials)
    }

    init(authenticatorState: AuthenticatorStateProtocol) {
        super.init(authenticatorState: authenticatorState,
                   credentials: Credentials())
    }

    /// Attempts to continue user's sign by providing email.
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func continueSignIn() async throws {
        setBusy(true)

        do {
            log.verbose("Attempting to continue Sign In with Email setup")
            let result = try await authenticationService.confirmSignIn(
                challengeResponse: email,
                options: nil
            )
            let nextStep = try await nextStep(for: result)

            setBusy(false)

            authenticatorState.setCurrentStep(nextStep)
        } catch {
            log.error("Continue Sign In with Email MFA Setup failed")
            let authenticationError = self.error(for: error)
            setMessage(authenticationError)
            throw authenticationError
        }
    }
}
