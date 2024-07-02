//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@_spi(InternalAmplifyConfiguration) import AWSCognitoAuthPlugin
import Foundation

/// Represents an error with the Amplify configuration
public struct AmplifyConfigurationError: Error, Equatable {
    private let name: String
    private init(name: String) {
        self.name = name
    }

    /// The Amplify Auth's plugin could not be retrieved
    public static let missingPlugin = AmplifyConfigurationError(name: "missingPlugin")

    /// The Amplify Auth's configuration is missing
    public static let missingConfiguration = AmplifyConfigurationError(name: "missingConfiguration")

    /// The Amplify Auth configuration exists but it has unexpected values
    public static let incorrectConfiguration = AmplifyConfigurationError(name: "incorrectConfiguration")
}

struct AmplifyConfiguration {
    var cognito: CognitoConfiguration

    init() throws {
        guard let plugin = try? Amplify.Auth.getPlugin(for: "awsCognitoAuthPlugin") as? AWSCognitoAuthPlugin else {
            Self.log.error("Unable to retrieve the AWSCognitoAuthPlugin")
            throw AmplifyConfigurationError.missingPlugin
        }

        switch plugin.authConfiguration {
        case .userPools(let configuration), .userPoolsAndIdentityPools(let configuration, _):
            self.cognito = CognitoConfiguration(
                usernameAttributes: configuration.usernameAttributes,
                signupAttributes: configuration.signUpAttributes,
                passwordProtectionSettings: configuration.passwordProtectionSettings ?? .init(minLength: 0, characterPolicy: []),
                verificationMechanisms: configuration.verificationMechanisms
            )
        case .identityPools, .none:
            Self.log.error("Unable to retrieve configuration from AWSCognitoAuthPlugin")
            throw AmplifyConfigurationError.missingConfiguration
        }
    }
}

struct CognitoConfiguration {

    var usernameAttributes: [UsernameAttribute]
    var signupAttributes: [SignUpAttributeType]
    var passwordProtectionSettings: PasswordProtectionSettings
    var verificationMechanisms: [VerificationMechanism]

    var usernameAttribute: UsernameAttribute {
        if let usernameAttribute = usernameAttributes.first {
            return usernameAttribute
        }

        return .username
    }

    static var empty: CognitoConfiguration {
        .init(
            usernameAttributes: [],
            signupAttributes: [],
            passwordProtectionSettings: .init(minLength: 0, characterPolicy: []),
            verificationMechanisms: [])
    }
}

extension AmplifyConfiguration: AuthenticatorLogging {}
