//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
@_spi(InternalAmplifyConfiguration)
@testable import AWSCognitoAuthPlugin
import Foundation

class AuthCategoryConfigurationFactory {
    static var shared = AuthCategoryConfigurationFactory()

    private var usernameAttributes: [JSONValue] = []
    private var signupAttributes: [JSONValue] = []
    private var verificationMechanisms: [JSONValue] = [
        .string("EMAIL")
    ]

    func createConfiguration() -> AuthCategoryConfiguration {
        return AuthCategoryConfiguration(plugins: [
            "awsCognitoAuthPlugin": [
                "CognitoUserPool": [
                    "Default": [
                        "PoolId": "PoolId",
                        "AppClientId": "AppClientId",
                        "Region": "us-east-1"
                    ]
                ],
                "CredentialsProvider": [
                    "CognitoIdentity": [
                        "Default": [
                            "PoolId": "PoolId",
                            "Region": "us-east-1"
                        ]
                    ]
                ],
                "Auth": [
                    "Default": [
                        "usernameAttributes": .array(usernameAttributes),
                        "signupAttributes": .array(signupAttributes),
                        "verificationMechanisms": .array(verificationMechanisms),
                        "passwordProtectionSettings": [
                            "passwordPolicyMinLength": 8,
                            "passwordPolicyCharacters": []
                        ]
                    ]
                ]
            ]
        ])
    }

    func setUserAtribute(_ userAttribute: UsernameAttribute) {
        usernameAttributes = [ .string(userAttribute.rawValue) ]
    }

    enum UsernameAttribute: String, Decodable {
        case username = "USERNAME"
        case email = "EMAIL"
        case phoneNumber = "PHONE_NUMBER"
    }
}




