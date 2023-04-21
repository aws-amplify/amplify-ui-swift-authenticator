//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation
import SwiftUI

/// The state observed by the Sign Up content view, representing the ``Authenticator`` is in the ``AuthenticatorStep/signUp`` step.
public class SignUpState: AuthenticatorBaseState {
    /// The Sign Up ``Field``s that are be displayed
    private(set) public var fields: [Field] = []

    /// Attempts to confirm the new password using the provided values.
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func signUp() async throws {
        setBusy(true)

        var username: String = ""
        var password: String?
        var attributes: [AuthUserAttribute] = []
        for field in fields {
            switch field.field.attributeType {
            case .username:
                username = field.value
            case .password:
                password = field.value
            default:
                if let key = field.field.attributeType.attributeKey {
                    attributes.append(
                        AuthUserAttribute(key, value: field.value)
                    )
                }
            }
        }

        do {
            log.verbose("Attempting to Sign Up")
            let result = try await authenticationService.signUp(
                username: username,
                password: password,
                options: .init(userAttributes: attributes)
            )
            let nextStep = try await nextStep(for: result)
            setBusy(false)
            credentials.username = username
            credentials.password = password
            authenticatorState.setCurrentStep(nextStep)
        } catch {
            log.error("Unable to Sign Up")
            let authenticationError = self.error(for: error)
            setMessage(authenticationError)
            throw authenticationError
        }
    }

    /// Manually moves the Authenticator to a different initial step
    /// - Parameter initialStep: The desired ``AuthenticatorInitialStep``
    public func move(to initialStep: AuthenticatorInitialStep) {
        authenticatorState.move(to: initialStep)
    }

    var password: String? {
        fields.first(where: { $0.field.attributeType == .password })?.value
    }

    func configure(with signUpFields: [SignUpField]) {
        guard self.fields.isEmpty else {
            log.error("Sign Up fields were already configured, ignoring")
            return
        }

        guard !signUpFields.isEmpty else {
            configureFromCognitoConfiguration()
            return
        }

        log.verbose("User provided custom Sign Up fields")

        setBusy(true)
        let cognitoConfiguration = authenticatorState.configuration
        var inputs = signUpFields.map { Field(field: $0) }
        for attribute in cognitoConfiguration.verificationMechanisms {
            if let index = inputs.firstIndex(where: { $0.field.attributeType == attribute.asSignUpAttribute }) {
                if !inputs[index].field.isRequired {
                    log.verbose("Marking verification attribute \(attribute.rawValue) as required")
                    inputs[index] = Field(field: .signUpField(from: attribute))
                }
            } else {
                log.verbose("Adding missing verification attribute \(attribute.rawValue) to Sign Up Fields")
                inputs.append(Field(field: .signUpField(from: attribute)))
            }
        }
        self.fields = inputs
        setBusy(false)
    }

    private func configureFromCognitoConfiguration() {
        log.verbose("Reading Sign Up attributes from the Cognito configuration")
        setBusy(true)
        let cognitoConfiguration = authenticatorState.configuration
        let initialSignUpFields: [SignUpField] = [
            .signUpField(from: cognitoConfiguration.usernameAttribute),
            .password(),
            .confirmPassword()
        ]

        for field in initialSignUpFields {
            fields.append(.init(field: field))
        }

        for attribute in cognitoConfiguration.signupAttributes {
            guard !fields.contains(where: { $0.field.attributeType == attribute.asSignUpAttribute } ) else {
                continue
            }

            let isVerificationAttribute = cognitoConfiguration.verificationMechanisms.contains {
                $0.rawValue == attribute.rawValue
            }
            let field: SignUpField = .signUpField(from: attribute, isRequired: isVerificationAttribute)
            fields.append(Field(field: field))
        }

        for attribute in cognitoConfiguration.verificationMechanisms {
            if !(fields.contains { $0.field.attributeType == attribute.asSignUpAttribute }){
                fields.append(Field(field: .signUpField(from: attribute)))
            }
        }

        setBusy(false)
    }
}

public extension SignUpState {
    /// Represents a pair between a `SignUpField` and the value that is provided by the user
    class Field: ObservableObject, Hashable {
        public let field: SignUpField
        @Published public var value: String = ""

        init(field: SignUpField) {
            self.field = field
        }

        public static func == (lhs: Field, rhs: Field) -> Bool {
            return lhs.field.attributeType == rhs.field.attributeType
        }

        public func hash(into hasher: inout Hasher) {
            return hasher.combine(field.attributeType)
        }
    }
}
