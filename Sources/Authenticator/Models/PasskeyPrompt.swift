//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Represents when to prompt users to create a passkey
public enum PasskeyPrompt: Equatable {
    /// Never prompt the user to create a passkey
    case never
    
    /// Always prompt the user to create a passkey
    case always
}

extension PasskeyPrompt: Codable {}

/// Configuration for when to prompt users to create passkeys
public struct PasskeyPrompts: Equatable {
    /// When to prompt after sign up
    public let afterSignUp: PasskeyPrompt
    
    /// When to prompt after sign in
    public let afterSignIn: PasskeyPrompt
    
    /// Creates a PasskeyPrompts configuration
    /// - Parameters:
    ///   - afterSignUp: When to prompt after sign up. Defaults to `.always`
    ///   - afterSignIn: When to prompt after sign in. Defaults to `.always`
    public init(afterSignUp: PasskeyPrompt = .always, afterSignIn: PasskeyPrompt = .always) {
        self.afterSignUp = afterSignUp
        self.afterSignIn = afterSignIn
    }
}

extension PasskeyPrompts: Codable {}
