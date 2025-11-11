//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Represents an authentication factor that can be used during sign-in
public enum AuthFactor: Equatable {
    /// Password authentication with optional SRP (Secure Remote Password)
    case password(srp: Bool = true)
    
    /// Email-based one-time password authentication
    case emailOtp
    
    /// SMS-based one-time password authentication
    case smsOtp
    
    /// WebAuthn/Passkey authentication
    case webAuthn
}

extension AuthFactor: Codable {}
