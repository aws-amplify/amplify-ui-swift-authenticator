//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//
import Foundation

/// Options for configuring the TOTP MFA Experience
public struct TOTPOptions {

    /// The `issuer` is the title displayed in a user's TOTP App preceding the
    /// account name. In most cases, this should be the name of your app.
    /// For example, if your app is called "My App", your user will see
    /// "My App" - "username" in their TOTP app.
    public let issuer: String?

    /// Creates a `TOTPOptions`
    /// - Parameter issuer: The `issuer` is the title displayed in a user's TOTP App
    public init(issuer: String? = nil) {
        self.issuer = issuer
    }
}
