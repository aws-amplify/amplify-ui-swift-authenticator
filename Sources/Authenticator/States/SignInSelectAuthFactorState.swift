//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// The state observed by the Sign In Select Auth Factor content view, representing the ``Authenticator`` is in the ``AuthenticatorStep/signInSelectAuthFactor`` step.
public class SignInSelectAuthFactorState: AuthenticatorBaseState {
    /// The password provided by the user (for password-based auth factors)
    @Published public var password: String = "" {
        didSet {
            credentials.password = password
        }
    }
    
    /// The selected authentication factor
    @Published public var selectedAuthFactor: AuthFactor?
    
    /// The username for this sign-in attempt
    public var username: String {
        return credentials.username
    }
    
    /// The available authentication factors for this user
    public let availableAuthFactors: [AuthFactor]
    
    init(credentials: Credentials, availableAuthFactors: [AuthFactor]) {
        self.availableAuthFactors = availableAuthFactors
        super.init(credentials: credentials)
    }
    
    init(authenticatorState: AuthenticatorStateProtocol, availableAuthFactors: [AuthFactor]) {
        self.availableAuthFactors = availableAuthFactors
        super.init(authenticatorState: authenticatorState,
                   credentials: Credentials())
    }
    
    /// Attempts to sign in using the selected authentication factor
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func selectAuthFactor() async throws {
        setBusy(true)
        
        // TODO: Implement selectAuthFactor logic
        // This should call the appropriate sign-in method based on selectedAuthFactor
        // For now, throw an error
        setBusy(false)
        fatalError("selectAuthFactor not yet implemented")
    }
    
    /// Manually moves the Authenticator to a different initial step
    /// - Parameter initialStep: The desired ``AuthenticatorInitialStep``
    public func move(to initialStep: AuthenticatorInitialStep) {
        authenticatorState.move(to: initialStep)
    }
}

extension SignInSelectAuthFactorState {
    enum Field: Int, Hashable, CaseIterable {
        case password
        case authFactor
    }
}
