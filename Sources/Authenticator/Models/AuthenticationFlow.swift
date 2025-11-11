//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Represents the authentication flow configuration for the Authenticator
public enum AuthenticationFlow: Equatable {
    /// Password-only authentication flow
    case password
    
    /// User choice authentication flow with optional preferred factor and passkey prompts
    case userChoice(preferredAuthFactor: AuthFactor? = nil, passkeyPrompts: PasskeyPrompts = .init())
}

extension AuthenticationFlow: Codable {}
