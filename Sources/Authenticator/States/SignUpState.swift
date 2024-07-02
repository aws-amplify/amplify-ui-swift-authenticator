//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation
import SwiftUI
@_spi(InternalAmplifyConfiguration) import AWSCognitoAuthPlugin

/// The state observed by the Sign Up content view, representing the ``Authenticator`` is in the ``AuthenticatorStep/signUp`` step.
public class SignUpState: AuthenticatorBaseState {
    /// The Sign Up ``Field``s that are displayed
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
                    // Check if the current AuthUserAttribute is defined to be the usernameAttribute in Cognito's config
                    if configuration.usernameAttribute == UsernameAttribute(from: key) {
                        username = field.value
                    }
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
            credentials.username = username
            credentials.password = password
            let nextStep = try await nextStep(for: result)
            setBusy(false)
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

        var existingFields: Set<SignUpAttribute> = []
        var inputs = signUpFields.compactMap { field -> Field? in
            guard !existingFields.contains(field.attributeType) else {
                log.warn("Skipping configuring field of type '\(field.rawValue)' because it was already present.")
                return nil
            }
            
            existingFields.insert(field.attributeType)
            return Field(field: field)
        }
        
        // Validate username attribute is present and required
        let usernameAttribute = cognitoConfiguration.usernameAttribute
        if existingFields.contains(usernameAttribute.asSignUpAttribute),
           let usernameField = inputs.first(where: { $0.field.attributeType == usernameAttribute.asSignUpAttribute }) {
            if !usernameField.isRequired {
                log.verbose("Marking username attribute \(usernameAttribute.rawValue) as required")
                usernameField.isRequired = true
            }
        } else {
            // Add username field at the top
            log.verbose("Adding missing username attribute \(usernameAttribute.rawValue) to Sign Up Fields")
            inputs.insert(.init(field: .signUpField(from: usernameAttribute)), at: 0)
            existingFields.insert(usernameAttribute.asSignUpAttribute)
        }
        
        // Validate all required sign up attributes are present
        for attribute in cognitoConfiguration.signupAttributes {
            if existingFields.contains(attribute.asSignUpAttribute),
               let field = inputs.first(where: { $0.field.attributeType == attribute.asSignUpAttribute }) {
                if !field.isRequired {
                    log.verbose("Marking sign up attribute \(attribute.rawValue) as required")
                    field.isRequired = true
                }
            } else {
                log.verbose("Adding missing required sign up attribute \(attribute.rawValue) to Sign Up Fields")
                inputs.append(.init(field: .signUpField(from: attribute, isRequired: true)))
                existingFields.insert(attribute.asSignUpAttribute)
            }
        }

        // Validate all verification attributes are present
        for attribute in cognitoConfiguration.verificationMechanisms {
            if existingFields.contains(attribute.asSignUpAttribute),
               let field = inputs.first(where: { $0.field.attributeType == attribute.asSignUpAttribute }) {
                if !field.isRequired {
                    log.verbose("Marking verification attribute \(attribute.rawValue) as required")
                    field.isRequired = true
                }
            } else {
                log.verbose("Adding missing verification attribute \(attribute.rawValue) to Sign Up Fields")
                inputs.append(.init(field: .signUpField(from: attribute)))
                existingFields.insert(attribute.asSignUpAttribute)
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

        var existingFields: Set<SignUpAttribute> = []
        for field in initialSignUpFields {
            fields.append(.init(field: field))
            existingFields.insert(field.attributeType)
        }

        // Add all required sign up attributes
        for attribute in cognitoConfiguration.signupAttributes where !existingFields.contains(attribute.asSignUpAttribute) {
            fields.append(.init(field: .signUpField(from: attribute, isRequired: true)))
            existingFields.insert(attribute.asSignUpAttribute)
        }

        // Add all verification mechanisms that might not be present
        for attribute in cognitoConfiguration.verificationMechanisms where !existingFields.contains(attribute.asSignUpAttribute) {
            fields.append(.init(field: .signUpField(from: attribute)))
            existingFields.insert(attribute.asSignUpAttribute)
        }

        setBusy(false)
    }
}

public extension SignUpState {
    /// Represents a pair between a `SignUpField` and the value that is provided by the user
    class Field: ObservableObject, Hashable {
        private(set) public var field: SignUpField
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
        
        var isRequired: Bool {
            set {
                guard isRequired != newValue else { return }
                switch field {
                case var baseField as BaseSignUpField:
                    baseField.isRequired = newValue
                    field = baseField
                case var customField as CustomSignUpField:
                    customField.isRequired = newValue
                    field = customField
                default:
                    log.error("Unsupported SignUpField of type \(type(of: self)) cannot be mutated")
                }
            }
            get {
                field.isRequired
            }
        }
    }
}

private extension SignUpField {
    var rawValue: String {
        switch attributeType {
        case .username:
            return "username"
        case .password:
            return "password"
        case .passwordConfirmation:
            return "passwordConfirmation"
        default:
            return attributeType.attributeKey?.rawValue ?? "unknown"
        }
    }
}
