//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import Foundation

/// Represents an authentication factor that can be used during sign-in
public enum AuthFactor: Equatable, Hashable {
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

extension AuthFactor {
    /// Translates AuthFactor to Amplify AuthFactorType
    func toAuthFactorType() -> AuthFactorType {
        switch self {
        case .password(let srp):
            return srp ? .passwordSRP : .password
        case .emailOtp:
            return .emailOTP
        case .smsOtp:
            return .smsOTP
        case .webAuthn:
            #if os(iOS) || os(macOS) || os(visionOS)
            if #available(iOS 17.4, macOS 13.5, visionOS 1.0, *) {
                return .webAuthn
            } else {
                // Fallback to password if WebAuthn not available
                return .passwordSRP
            }
            #else
            // Fallback to password on unsupported platforms
            return .passwordSRP
            #endif
        }
    }
    
    /// Returns true if this auth factor is a password-based factor (with or without SRP)
    var isPassword: Bool {
        if case .password = self {
            return true
        }
        return false
    }
    
    /// Returns true if this auth factor is password with SRP enabled
    var isPasswordWithSRP: Bool {
        guard case .password(let srp) = self else {
            return false
        }
        return srp
    }
    
    /// Display priority for sorting auth factors
    /// Lower values appear first: WebAuthn (1), SMS (2), Email (3), Password (4)
    var displayPriority: Int {
        switch self {
        case .webAuthn:
            return 1
        case .smsOtp:
            return 2
        case .emailOtp:
            return 3
        case .password:
            return 4
        }
    }
}

extension Array where Element == AuthFactor {
    /// Returns true if the array contains any password-based auth factor
    var containsPassword: Bool {
        return contains(where: { $0.isPassword })
    }
    
    /// Returns the preferred password-based auth factor
    /// Prefers passwordSRP over password when both are available (more secure)
    var preferredPasswordFactor: AuthFactor? {
        // First, try to find password with SRP (more secure)
        if let passwordSRP = first(where: { $0.isPasswordWithSRP }) {
            return passwordSRP
        }
        
        // Fall back to password without SRP
        return first(where: { $0.isPassword })
    }
    
    /// Returns all non-password auth factors sorted by priority
    /// Order: WebAuthn (Passkey), SMS OTP, Email OTP
    var nonPasswordFactors: [AuthFactor] {
        return filter { !$0.isPassword }.sorted { factor1, factor2 in
            return factor1.displayPriority < factor2.displayPriority
        }
    }
}
