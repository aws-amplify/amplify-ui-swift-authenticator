//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
@_spi(InternalAmplifyConfiguration) import AWSCognitoAuthPlugin

/// Represents an error associated with a Field, typically displayed beneath it.
public typealias FieldError = CustomStringConvertible

/// A closure that takes a `String` and returns an optional `FieldError`.
/// If the value matches the expectations, `nil` is expected to be returned.
public typealias FieldValidator = (_ content: String) -> FieldError?

/// A collection of ``FieldValidator``
public struct FieldValidators {

    /// Represents a policy for password characters
    public struct PasswordCharactersPolicy: Equatable {
        private let name: String
        private init(name: String) {
            self.name = name
        }

        /// Requires that at least one character is lowercase
        public static let requiresLowercase: Self = .init(name: "requiresLowercase")

        /// Requires that at least one character is uppercase
        public static let requiresUppercase: Self = .init(name: "requiresUppercase")

        /// Requires that at least one character is numeric
        public static let requiresNumbers: Self = .init(name: "requiresNumbers")

        /// Requires that at least one character is a special character
        ///
        /// A special character is one of the following:
        /// ~~~
        /// ^ $ * . [ ] { } ( ) ? " ! @ # % & / \ , > < ' : ; | _ ~ ` = + -
        /// ~~~
        public static let requiresSymbols: Self = .init(name: "requiresSymbols")

        init(from policy: PasswordCharacterPolicy) {
            switch policy {
            case .lowercase:
                self = .requiresLowercase
            case .uppercase:
                self = .requiresUppercase
            case .numbers:
                self = .requiresNumbers
            case .symbols:
                self = .requiresSymbols
            }
        }
    }

    /// Requires that the provided value is not empty
    public static var required: FieldValidator = { content in
        return content.isEmpty ? "authenticator.validator.field.required".localized() : nil
    }

    /// Requires that the provided value follows a phone format
    public static var phoneNumber: FieldValidator = { content in
        guard content.hasPrefix("+"),
              content.count > 1,
              content.count <= 16
        else {
            return "authenticator.validator.field.phoneNumber.format".localized()
        }

        return nil
    }

    /// Requires that the provided value follows an email format
    public static var email: FieldValidator = { content in
        let emailPattern = #"^\S+@\S+\.\S+$"#
        let validation = content.range(
            of: emailPattern,
            options: .regularExpression
        )

        return validation == nil ? "authenticator.validator.field.email.format".localized() : nil
    }

    /// Requires that the provided value complies with the provided password policies
    /// - Parameter minLength: The password minimum length
    /// - Parameter characterPolicy: An array of  ``PasswordCharactersPolicy`` that the password should meet.
    ///
    public static func password(
        minLength: Int,
        characterPolicy: [PasswordCharactersPolicy] = []
    ) -> FieldValidator {
        return { content in
            if let error = required(content) {
                return error
            }

            let title = "authenticator.validator.field.conditions.title".localized(
                using: "authenticator.field.password.label".localized()
            )

            var failedConditions: [String] = []
            if content.count < minLength {
                failedConditions.append("authenticator.validator.field.conditions.length".localized(using:minLength))
            }

            for policy in characterPolicy {
                switch policy {
                case .requiresNumbers:
                    if content.rangeOfCharacter(from: .decimalDigits) == nil {
                        failedConditions.append("authenticator.validator.field.conditions.requiresNumbers".localized())
                    }
                case .requiresSymbols:
                    let specialSymbols = CharacterSet(charactersIn: "^$*.[]{}()?\"!@#%&/\\,><':;|_~`=+-")
                    if content.rangeOfCharacter(from: specialSymbols) == nil {
                        failedConditions.append("authenticator.validator.field.conditions.requiresSymbols".localized())
                    }
                case .requiresLowercase:
                    if content.rangeOfCharacter(from: .lowercaseLetters) == nil {
                        failedConditions.append("authenticator.validator.field.conditions.requiresLowercase".localized())
                    }
                case .requiresUppercase:
                    if content.rangeOfCharacter(from: .uppercaseLetters) == nil {
                        failedConditions.append("authenticator.validator.field.conditions.requiresUppercase".localized())
                    }
                default:
                    break
                }
            }

            if failedConditions.isEmpty {
                return nil
            }

            return "\(title)\n\(failedConditions.joined(separator: "\n"))"
        }
    }

    /// A convenience empty validator
    public static var none: FieldValidator = { _ in
        return nil
    }

    /// Returns a validator that chains the provided ones
    /// - Parameter validators: One or more ``FieldValidator`` that will be combined
    public static func combined(_ validators: FieldValidator...) -> FieldValidator {
        let combined: FieldValidator = { value in
            for validator in validators {
                if let error = validator(value) {
                    return error
                }
            }
            return nil
        }
        return combined
    }
}

extension Array where Element == PasswordCharacterPolicy {

    func asPasswordCharactersPolicy() -> [FieldValidators.PasswordCharactersPolicy] {
        return compactMap { FieldValidators.PasswordCharactersPolicy(from: $0) }
    }
}
