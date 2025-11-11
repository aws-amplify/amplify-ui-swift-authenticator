//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// The state observed by the Passkey Created content view, representing the ``Authenticator`` is in the ``AuthenticatorStep/passkeyCreated`` step.
public class PasskeyCreatedState: AuthenticatorBaseState {
    
    override init(credentials: Credentials) {
        super.init(credentials: credentials)
    }
    
    init(authenticatorState: AuthenticatorStateProtocol) {
        super.init(authenticatorState: authenticatorState,
                   credentials: Credentials())
    }
    
    /// Continues the authentication flow after passkey creation
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func `continue`() async throws {
        setBusy(true)
        
        // TODO: Implement continue logic
        // This should move to the next appropriate step after passkey creation
        setBusy(false)
        fatalError("continue not yet implemented")
    }
}
