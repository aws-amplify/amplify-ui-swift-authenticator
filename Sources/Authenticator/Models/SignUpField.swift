//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents a field that is displayed in the Sign Up view
public protocol SignUpField {
    var isRequired: Bool { get }
    var attributeType: SignUpAttribute { get }
    var validator: FieldValidator? { get }
}

/// A field that is displayed using the Authenticator's default input fields
public struct BaseSignUpField: SignUpField {
    public let label: String
    public let placeholder: String
    public let isRequired: Bool
    public let attributeType: SignUpAttribute
    public let validator: FieldValidator?
    let inputType: InputType

    init(
        label: String,
        placeholder: String,
        isRequired: Bool = false,
        attributeType: SignUpAttribute,
        inputType: InputType = .text,
        validator: FieldValidator? = nil
    ) {
        if isRequired {
            self.label = label
        } else {
            self.label = .field_label_optional.localized(using: label)
        }
        self.placeholder = placeholder
        self.isRequired = isRequired
        self.attributeType = attributeType
        self.inputType = inputType
        self.validator = validator
    }
}

/// A field that is displayed using a provided custom View
public struct CustomSignUpField: SignUpField {
    public let label: String?
    public let isRequired: Bool
    public let attributeType: SignUpAttribute
    public let validator: FieldValidator?
    public let content: (Binding<String>) -> any View
    public let errorContent: (String) -> any View

    init(
        label: String?,
        isRequired: Bool,
        attributeType: SignUpAttribute,
        validator: FieldValidator?,
        content: @escaping (Binding<String>) -> any View,
        errorContent: @escaping (String) -> any View
    ) {
        self.label = label
        self.isRequired = isRequired
        self.attributeType = attributeType
        self.validator = validator
        self.content = content
        self.errorContent = errorContent
    }
}


public extension SignUpField where Self == BaseSignUpField {
    /// The user's username field
    static func username() -> SignUpField {
        return signUpField(
            label: .field_username_label.localized(),
            placeholder: .field_username_placeholder.localized(),
            isRequired: true,
            attributeType: .username,
            validator: FieldValidators.required
        )
    }

    /// The user's password field
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to true.
    static func password(isRequired: Bool = true) -> SignUpField {
        return signUpField(
            label: .field_password_label.localized(),
            placeholder: .field_password_placeholder.localized(),
            isRequired: isRequired,
            attributeType: .password,
            inputType: .password
        )
    }

    /// The user's password confirmation field
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to true.
    static func confirmPassword(isRequired: Bool = true) -> SignUpField {
        return signUpField(
            label: .field_confirmPassword_label.localized(),
            placeholder: .field_confirmPassword_placeholder.localized(),
            isRequired: isRequired,
            attributeType: .passwordConfirmation,
            inputType: .password
        )
    }

    /// The user's email field
    ///
    /// Associated with the `AuthUserAttributeKey.email` attribute key
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to false.
    static func email(isRequired: Bool = false) -> SignUpField {
        return signUpField(
            label: .field_email_label.localized(),
            placeholder: .field_email_placeholder.localized(),
            isRequired: isRequired,
            attributeType: .email,
            validator: FieldValidators.email
        )
    }

    /// The user's address field
    ///
    /// Associated with the `AuthUserAttributeKey.address` attribute key
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to false.
    static func address(isRequired: Bool = false) -> SignUpField {
        return signUpField(
            label: .field_address_label.localized(),
            placeholder: .field_address_placeholder.localized(),
            isRequired: isRequired,
            attributeType: .address
        )
    }

    /// The user's phone number field
    ///
    /// Associated with the `AuthUserAttributeKey.phoneNumber` attribute key
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to false.
    static func phoneNumber(isRequired: Bool = false) -> SignUpField {
        return signUpField(
            label: .field_phoneNumber_label.localized(),
            placeholder: .field_phoneNumber_placeholder.localized(),
            isRequired: isRequired,
            attributeType: .phoneNumber,
            inputType: .phoneNumber,
            validator: FieldValidators.phoneNumber
        )
    }

    /// The user's birth date field
    ///
    /// Associated with the `AuthUserAttributeKey.birthDate` attribute key
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to false.
    static func birthDate(isRequired: Bool = false) -> SignUpField {
        return signUpField(
            label: .field_birthDate_label.localized(),
            placeholder: .field_birthDate_placeholder.localized(),
            isRequired: isRequired,
            attributeType: .birthDate,
            inputType: .date
        )
    }

    /// The user's gender field
    ///
    /// Associated with the `AuthUserAttributeKey.gender` attribute key
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to false.
    static func gender(isRequired: Bool = false) -> SignUpField {
        return signUpField(
            label: .field_gender_label.localized(),
            placeholder: .field_gender_placeholder.localized(),
            isRequired: isRequired,
            attributeType: .gender
        )
    }

    /// The user's given name field
    ///
    /// Associated with the `AuthUserAttributeKey.givenName` attribute key
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to false.
    static func givenName(isRequired: Bool = false) -> SignUpField {
        return signUpField(
            label: .field_givenName_label.localized(),
            placeholder: .field_givenName_placeholder.localized(),
            isRequired: isRequired,
            attributeType: .givenName
        )
    }

    /// The user's middle name field
    ///
    /// Associated with the `AuthUserAttributeKey.middleName` attribute key
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to false.
    static func middleName(isRequired: Bool = false) -> SignUpField {
        return signUpField(
            label: .field_middleName_label.localized(),
            placeholder: .field_middleName_placeholder.localized(),
            isRequired: isRequired,
            attributeType: .middleName
        )
    }

    /// The user's family name field
    ///
    /// Associated with the `AuthUserAttributeKey.familyName` attribute key
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to false.
    static func familyName(isRequired: Bool = false) -> SignUpField {
        return signUpField(
            label: .field_familyName_label.localized(),
            placeholder: .field_familyName_placeholder.localized(),
            isRequired: isRequired,
            attributeType: .familyName
        )
    }

    /// The user's name field
    ///
    /// Associated with the `AuthUserAttributeKey.name` attribute key
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to false.
    static func name(isRequired: Bool = false) -> SignUpField {
        return signUpField(
            label: .field_name_label.localized(),
            placeholder: .field_name_placeholder.localized(),
            isRequired: isRequired,
            attributeType: .name
        )
    }

    /// The user's nickname field
    ///
    /// Associated with the `AuthUserAttributeKey.nickname` attribute key
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to false.
    static func nickname(isRequired: Bool = false) -> SignUpField {
        return signUpField(
            label: .field_nickname_label.localized(),
            placeholder: .field_nickname_placeholder.localized(),
            isRequired: isRequired,
            attributeType: .nickname
        )
    }

    /// The user's preferred username field
    ///
    /// Associated with the `AuthUserAttributeKey.preferredUsername` attribute key
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to false.
    static func preferredUsername(isRequired: Bool = false) -> SignUpField {
        return signUpField(
            label: .field_preferredUsername_label.localized(),
            placeholder: .field_preferredUsername_placeholder.localized(),
            isRequired: isRequired,
            attributeType: .preferredUsername
        )
    }

    /// The user's profile field
    ///
    /// Associated with the `AuthUserAttributeKey.profile` attribute key
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to false.
    static func profile(isRequired: Bool = false) -> SignUpField {
        return signUpField(
            label: .field_profile_label.localized(),
            placeholder: .field_profile_placeholder.localized(),
            isRequired: isRequired,
            attributeType: .profile
        )
    }

    /// The user's website field
    ///
    /// Associated with the `AuthUserAttributeKey.website` attribute key
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to false.
    static func website(isRequired: Bool = false) -> SignUpField {
        return signUpField(
            label: .field_website_label.localized(),
            placeholder: .field_website_placeholder.localized(),
            isRequired: isRequired,
            attributeType: .website
        )
    }

    /// A text-based field associated with the given attribute key
    /// - Parameter key: The `AuthUserAttributeKey`
    /// - Parameter label: The label that is displayed above the field
    /// - Parameter placeholder: The placeholder that is displayed in the field
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to false.
    /// - Parameter maxLength: The maximum length this field's value can have. Defaults to 2048
    /// - Parameter validator: An additional validator that will be invoked before proceeding. Defaults to nil
    static func text(
        key: AuthUserAttributeKey,
        label: String,
        placeholder: String,
        isRequired: Bool = false,
        maxLength: Int = 2048,
        validator: FieldValidator? = nil
    ) -> SignUpField {
        return signUpField(
            label: label,
            placeholder: placeholder,
            isRequired: isRequired,
            attributeType: .custom(attributeKey: key),
            validator: validator
        )
    }

    /// A date-based field associated with the given attribute key
    /// - Parameter key: The `AuthUserAttributeKey`
    /// - Parameter label: The label that is displayed along the field
    /// - Parameter isRequired: Whether the view will require a date to be entered before proceeding. Defaults to false.
    /// - Parameter minDate: The minimum date this field's value can be set to. Defaults to nil
    /// - Parameter maxDate: The maximum date this field's value can be set to. Defaults to nil
    /// - Parameter validator: An additional validator that will be invoked before proceeding. Defaults to nil
    static func date(
        key: AuthUserAttributeKey,
        label: String,
        isRequired: Bool = false,
        minDate: Date? = nil,
        maxDate: Date? = nil,
        validator: FieldValidator? = nil
    ) -> SignUpField {
        return signUpField(
            label: label,
            placeholder: "",
            isRequired: isRequired,
            attributeType: .custom(attributeKey: key),
            inputType: .date,
            validator: { value in
                let dateFormatter = ISO8601DateFormatter()
                let defaultFormatter = DateFormatter()
                defaultFormatter.dateStyle = .short
                if let date = dateFormatter.date(from: value) {
                    if let minDate = minDate, date < minDate {
                        return String.validator_field_date_minDate.localized(
                            using: label, defaultFormatter.string(from: minDate)
                        )
                    }

                    if let maxDate = maxDate, date > maxDate {
                        return String.validator_field_date_maxDate.localized(
                            using: label, defaultFormatter.string(from: maxDate)
                        )
                    }
                }

                if let validator = validator {
                    return validator(value)
                }

                return nil
            }
        )
    }

    /// A phone number-based field associated with the given attribute key
    /// - Parameter key: The `AuthUserAttributeKey`
    /// - Parameter label: The label that is displayed above the field
    /// - Parameter placeholder: The placeholder that is displayed in the field
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to false.
    /// - Parameter validator: An additional validator that will be invoked before proceeding. Defaults to nil
    static func phoneNumber(
        key: AuthUserAttributeKey,
        label: String,
        placeholder: String,
        isRequired: Bool = false,
        validator: FieldValidator? = nil
    ) -> SignUpField {
        return signUpField(
            label: label,
            placeholder: placeholder,
            isRequired: isRequired,
            attributeType: .custom(attributeKey: key),
            inputType: .phoneNumber,
            validator: validator
        )
    }
}

extension SignUpField where Self == BaseSignUpField {
    static func signUpField(
        label: String,
        placeholder: String,
        isRequired: Bool = false,
        attributeType: SignUpAttribute,
        inputType: InputType = .text,
        maxLength: Int = 2048,
        validator: FieldValidator? = nil
    ) -> SignUpField {
        return BaseSignUpField(
            label: label,
            placeholder: placeholder,
            isRequired: isRequired,
            attributeType: attributeType,
            inputType: inputType,
            validator: { value in
                if value.count > maxLength {
                    return String.validator_field_maxLength.localized(
                        using: label, maxLength
                    )
                }

                if let validator = validator {
                    return validator(value)
                }

                return nil
            }
        )
    }

    static func signUpField(
        from attribute: CognitoConfiguration.SignUpAttribute,
        isRequired: Bool
    ) -> SignUpField {
        switch attribute {
        case .address:
            return .address(isRequired: isRequired)
        case .birthDate:
            return .birthDate(isRequired: isRequired)
        case .email:
            return .email(isRequired: isRequired)
        case .familyName:
            return .familyName(isRequired: isRequired)
        case .gender:
            return .gender(isRequired: isRequired)
        case .givenName:
            return .givenName(isRequired: isRequired)
        case .middleName:
            return .middleName(isRequired: isRequired)
        case .name:
            return .name(isRequired: isRequired)
        case .nickname:
            return .nickname(isRequired: isRequired)
        case .phoneNumber:
            return .phoneNumber(isRequired: isRequired)
        case .preferredUsername:
            return .preferredUsername(isRequired: isRequired)
        case .profile:
            return .profile(isRequired: isRequired)
        case .website:
            return .website(isRequired: isRequired)
        }
    }

    static func signUpField(
        from attribute: CognitoConfiguration.VerificationMechanism
    ) -> SignUpField {
        switch attribute {
        case .email:
            return .email(isRequired: true)
        case .phoneNumber:
            return .phoneNumber(isRequired: true)
        }
    }

    static func signUpField(
        from attribute: CognitoConfiguration.UsernameAttribute
    ) -> SignUpField {
        switch attribute {
        case .username:
            return .username()
        case .email:
            return .email(isRequired: true)
        case .phoneNumber:
            return .phoneNumber(isRequired: true)
        }
    }
}

public extension SignUpField where Self == CustomSignUpField {

    /// A fully custom field associated with the given Sign Up attribute
    /// - Parameter label: The label that is displayed above the field
    /// - Parameter isRequired: Whether the view will require a value to be entered before proceeding. Defaults to false.
    /// - Parameter attributeType: The `SignUpAttribute`
    /// - Parameter validator: An additional validator that will be invoked before proceeding. Defaults to nil
    /// - Parameter errorContent: A closure that takes a `String` and returns a `View`, invoked when there is a validation failure. Defaults to a simple `Text` displaying the error.
    /// - Parameter content: A closure that takes a `Binding<String>` and returns a `View` that represents the field.
    static func custom<Content: View, ErrorContent: View>(
        label: String? = nil,
        isRequired: Bool = false,
        attributeType: SignUpAttribute,
        validator: FieldValidator? = nil,
        errorContent: @escaping (String) -> ErrorContent = { error in
            SwiftUI.Text(error)
        },
        content: @escaping (Binding<String>) -> Content
    ) -> SignUpField {
        return CustomSignUpField(
            label: label,
            isRequired: isRequired,
            attributeType: attributeType,
            validator: validator,
            content: content,
            errorContent: errorContent
        )
    }
}
