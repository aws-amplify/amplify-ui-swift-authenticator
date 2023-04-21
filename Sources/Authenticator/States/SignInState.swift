//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

/// The state observed by the Sign In content view, representing the ``Authenticator`` is in the ``AuthenticatorStep/signIn`` step.
public class SignInState: AuthenticatorBaseState {
    /// The username provided by the user. Note that this could be an email and a phone number as well.
    @Published public var username: String = "" {
        didSet {
            credentials.username = username
        }
    }
    /// The password provided by the user
    @Published public var password: String = "" {
        didSet {
            credentials.password = password
        }
    }

    /// Attempts to sign in using the provided credentials
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and `AuthenticatorBaseState/message` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func signIn() async throws {
        setBusy(true)

        do {
            log.verbose("Attempting to Sign In")
            let result = try await authenticationService.signIn(
                username: username.isEmpty ? nil : username,
                password: password.isEmpty ? nil : password,
                options: nil
            )
            let nextStep = try await nextStep(for: result)
            setBusy(false)
            authenticatorState.setCurrentStep(nextStep)
        } catch {
            log.error("Unable to Sign In")
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

extension SignInState {
    enum Field: Int, Hashable, CaseIterable {
        case username
        case password
    }
}
