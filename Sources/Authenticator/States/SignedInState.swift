//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation

/// The state that represents that the Authenticator is in `.signedIn` step
/// It can be retrieved through `@EnvironmentObject var state: SignedInState`, but it will only be set once the Authenticator successfuly completes an authentication flow.
public class SignedInState: ObservableObject {
    /// The signed in user
    public let user: AuthUser
    let authenticationService: AuthenticationService

    init(user: AuthUser, authenticationService: AuthenticationService) {
        self.user = user
        self.authenticationService = authenticationService
    }

    /// Performs a sign out.
    /// - Returns: A `AuthSignOutResult`
    @discardableResult public func signOut() async -> AuthSignOutResult {
        let result = await authenticationService.signOut(options: nil)
        log.verbose("Sign out result is \(result)")
        return result
    }
}

extension SignedInState: AuthenticatorLogging {}
