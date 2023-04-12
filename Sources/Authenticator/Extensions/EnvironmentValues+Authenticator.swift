//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

extension EnvironmentValues {
    /// The Authenticator's ``AuthenticatorState``
    public var authenticatorState: AuthenticatorState {
        get {
            self[AuthenticatorStateKey.self]
        }

        set {
            self[AuthenticatorStateKey.self] = newValue
        }
    }
}

extension EnvironmentValues {
    var authenticatorTheme: AuthenticatorTheme {
        get {
            self[AuthenticationThemeKey.self]
        }

        set {
            self[AuthenticationThemeKey.self] = newValue
        }
    }

    var authenticationService: AuthenticationService {
        get {
            self[AuthenticationServiceKey.self]
        }

        set {
            self[AuthenticationServiceKey.self] = newValue
        }
    }

    var authenticatorOptions: AuthenticatorOptions {
        get {
            self[AuthenticatorOptionsKey.self]
        }

        set {
            self[AuthenticatorOptionsKey.self] = newValue
        }
    }
}

private struct AuthenticatorStateKey: EnvironmentKey {
    static let defaultValue: AuthenticatorState = .init()
}

private struct AuthenticationThemeKey: EnvironmentKey {
    static let defaultValue: AuthenticatorTheme = AuthenticatorTheme()
}

private struct AuthenticationServiceKey: EnvironmentKey {
    static let defaultValue: AuthenticationService = .default
}

private struct AuthenticatorOptionsKey: EnvironmentKey {
    static let defaultValue: AuthenticatorOptions = .init()
}
