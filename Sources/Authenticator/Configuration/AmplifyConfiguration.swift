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

        guard let configuration = plugin.jsonConfiguration,
              let cognitoConfiguration = configuration.value(at: "Auth.Default") else {
            Self.log.error("Unable to read Auth.Default from the configuration")
            throw AmplifyConfigurationError.missingConfiguration
        }

        guard case .object(let passwordSettings) = cognitoConfiguration["passwordProtectionSettings"] else {
            Self.log.error("passwordProtectionSettings is missing")
            throw AmplifyConfigurationError.incorrectConfiguration
        }

        var minLength: Int
        if case .number(let value) = passwordSettings["passwordPolicyMinLength"] {
            minLength = Int(value)
        } else if case .string(let value) = passwordSettings["passwordPolicyMinLength"],
                  let intValue = Int(value) {
            minLength = intValue
        } else {
            Self.log.error("passwordPolicyMinLength is missing")
            throw AmplifyConfigurationError.incorrectConfiguration
        }

        var characterPolicy: [CognitoConfiguration.PasswordCharacterPolicy] = []
        if case .array(let characters) = passwordSettings["passwordPolicyCharacters"] {
            characterPolicy = characters.compactMap { value in
                guard case .string(let string) = value else {
                    return nil
                }

                return .init(rawValue: string)
            }
        }

        let passwordProtectionSettings = CognitoConfiguration.PasswordProtectionSettings(
            minLength: minLength,
            characterPolicy: characterPolicy
        )

        var usernameAttributes: [CognitoConfiguration.UsernameAttribute] = []
        if case .array(let attributes) = cognitoConfiguration["usernameAttributes"] {
            usernameAttributes = attributes.compactMap { value in
                guard case .string(let string) = value else {
                    return nil
                }

                return .init(rawValue: string)
            }
        }

        var signUpAttributes: [CognitoConfiguration.SignUpAttribute] = []
        if case .array(let attributes) = cognitoConfiguration["signupAttributes"] {
            signUpAttributes = attributes.compactMap { value in
                guard case .string(let string) = value else {
                    return nil
                }

                return .init(rawValue: string)
            }
        }

        var verificationMechanisms: [CognitoConfiguration.VerificationMechanism] = []
        if case .array(let attributes) = cognitoConfiguration["verificationMechanisms"] {
            verificationMechanisms = attributes.compactMap { value in
                guard case .string(let string) = value else {
                    return nil
                }

                return .init(rawValue: string)
            }
        }

        var hasIdentityPool = false
        if let cognitoConfiguration = configuration.value(at: "CredentialsProvider.CognitoIdentity.Default"),
           case .string(let poolId) = cognitoConfiguration["PoolId"], !poolId.isEmpty {
            hasIdentityPool = true
        }

        var hasUserPool = false
        if let cognitoConfiguration = configuration.value(at: "CognitoUserPool.Default"),
           case .string(let poolId) = cognitoConfiguration["PoolId"], !poolId.isEmpty {
            hasUserPool = true
        }

        self.cognito = CognitoConfiguration(
            usernameAttributes: usernameAttributes,
            signupAttributes: signUpAttributes,
            passwordProtectionSettings: passwordProtectionSettings,
            verificationMechanisms: verificationMechanisms,
            hasUserPool: hasUserPool,
            hasIdentityPool: hasIdentityPool
        )
    }
}

struct CognitoConfiguration {
    enum UsernameAttribute: String, Decodable {
        case username = "USERNAME"
        case email = "EMAIL"
        case phoneNumber = "PHONE_NUMBER"
        
        init?(from authUserAttributeKey: AuthUserAttributeKey) {
            switch authUserAttributeKey {
            case .email:
                self = .email
            case .phoneNumber:
                self = .phoneNumber
            default:
                return nil
            }
        }
    }

    enum SignUpAttribute: String, Decodable {
        case address = "ADDRESS"
        case birthDate = "BIRTHDATE"
        case email = "EMAIL"
        case familyName = "FAMILY_NAME"
        case gender = "GENDER"
        case givenName = "GIVEN_NAME"
        case middleName = "MIDDLE_NAME"
        case name = "NAME"
        case nickname = "NICKNAME"
        case phoneNumber = "PHONE_NUMBER"
        case preferredUsername = "PREFERRED_USERNAME"
        case profile = "PROFILE"
        case website = "WEBSITE"
    }

    enum VerificationMechanism: String, Decodable {
        case email = "EMAIL"
        case phoneNumber = "PHONE_NUMBER"
    }

    enum PasswordCharacterPolicy: String, Decodable {
        case lowercase = "REQUIRES_LOWERCASE"
        case uppercase = "REQUIRES_UPPERCASE"
        case numbers = "REQUIRES_NUMBERS"
        case symbols = "REQUIRES_SYMBOLS"
    }

    struct PasswordProtectionSettings: Decodable {
        var minLength: Int
        var characterPolicy: [PasswordCharacterPolicy]
    }

    var usernameAttributes: [UsernameAttribute]
    var signupAttributes: [SignUpAttribute]
    var passwordProtectionSettings: PasswordProtectionSettings
    var verificationMechanisms: [VerificationMechanism]

    var usernameAttribute: UsernameAttribute {
        if let usernameAttribute = usernameAttributes.first {
            return usernameAttribute
        }

        return .username
    }

    var hasUserPool: Bool
    var hasIdentityPool: Bool

    static var empty: CognitoConfiguration {
        .init(
            usernameAttributes: [],
            signupAttributes: [],
            passwordProtectionSettings: .init(minLength: 0, characterPolicy: []),
            verificationMechanisms: [],
            hasUserPool: false,
            hasIdentityPool: false
        )
    }
}

extension AmplifyConfiguration: AuthenticatorLogging {}
