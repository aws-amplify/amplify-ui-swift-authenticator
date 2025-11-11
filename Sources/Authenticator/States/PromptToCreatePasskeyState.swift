//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// The state observed by the Prompt To Create Passkey content view, representing the ``Authenticator`` is in the ``AuthenticatorStep/promptToCreatePasskey`` step.
public class PromptToCreatePasskeyState: AuthenticatorBaseState {
    
    override init(credentials: Credentials) {
        super.init(credentials: credentials)
    }
    
    init(authenticatorState: AuthenticatorStateProtocol) {
        super.init(authenticatorState: authenticatorState,
                   credentials: Credentials())
    }
    
    /// Attempts to create a passkey for the user
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func createPasskey() async throws {
        setBusy(true)
        
        // TODO: Implement createPasskey logic
        // This should call the passkey creation API
        setBusy(false)
        fatalError("createPasskey not yet implemented")
    }
    
    /// Skips passkey creation and continues with the authentication flow
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func skip() async throws {
        setBusy(true)
        
        // TODO: Implement skip logic
        // This should move to the next appropriate step without creating a passkey
        setBusy(false)
        fatalError("skip not yet implemented")
    }
}
