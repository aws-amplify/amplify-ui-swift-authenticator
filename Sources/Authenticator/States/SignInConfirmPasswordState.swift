//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// The state observed by the Sign In Confirm Password content view, representing the ``Authenticator`` is in the ``AuthenticatorStep/signInConfirmPassword`` step.
public class SignInConfirmPasswordState: AuthenticatorBaseState {
    /// The password provided by the user
    @Published public var password: String = "" {
        didSet {
            credentials.password = password
        }
    }
    
    /// The username for this sign-in attempt
    public var username: String {
        return credentials.username
    }
    
    override init(credentials: Credentials) {
        super.init(credentials: credentials)
    }
    
    init(authenticatorState: AuthenticatorStateProtocol) {
        super.init(authenticatorState: authenticatorState,
                   credentials: Credentials())
    }
    
    /// Attempts to confirm the password and complete sign-in
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func confirmPassword() async throws {
        setBusy(true)
        
        // TODO: Implement confirmPassword logic
        // This should call the appropriate sign-in method with the password
        setBusy(false)
        fatalError("confirmPassword not yet implemented")
    }
    
    /// Manually moves the Authenticator to a different initial step
    /// - Parameter initialStep: The desired ``AuthenticatorInitialStep``
    public func move(to initialStep: AuthenticatorInitialStep) {
        authenticatorState.move(to: initialStep)
    }
}

extension SignInConfirmPasswordState {
    enum Field: Int, Hashable, CaseIterable {
        case password
    }
}
