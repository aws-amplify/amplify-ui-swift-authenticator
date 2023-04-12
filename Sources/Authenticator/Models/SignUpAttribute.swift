//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation
import SwiftUI

/// Represents to which Sign Up attribute a field is associated with.
public enum SignUpAttribute: Equatable, Hashable {
    case username
    case password
    case passwordConfirmation
    case email
    case address
    case birthDate
    case givenName
    case middleName
    case familyName
    case name
    case nickname
    case gender
    case phoneNumber
    case preferredUsername
    case profile
    case website
#if canImport(UIKit)
    case custom(attributeKey: AuthUserAttributeKey, textContentType: UITextContentType? = nil)
#else
    case custom(attributeKey: AuthUserAttributeKey)
#endif

    var attributeKey: AuthUserAttributeKey? {
        switch self {
        case .username:
            return nil
        case .password:
            return nil
        case .passwordConfirmation:
            return nil
        case .email:
            return .email
        case .address:
            return .address
        case .birthDate:
            return .birthDate
        case .givenName:
            return .givenName
        case .middleName:
            return .middleName
        case .familyName:
            return .familyName
        case .name:
            return .name
        case .nickname:
            return .nickname
        case .gender:
            return .gender
        case .phoneNumber:
            return .phoneNumber
        case .preferredUsername:
            return .preferredUsername
        case .profile:
            return .profile
        case .website:
            return .website
#if canImport(UIKit)
        case .custom(let attributeKey, _):
            return attributeKey
#else
        case .custom(let attributeKey):
            return attributeKey
#endif
        }
    }

#if canImport(UIKit)
    var keyboardType: UIKeyboardType {
        switch self {
        case .email:
            return .emailAddress
        case .phoneNumber:
            return .phonePad
        default:
            return .default
        }
    }

    var textContentType: UITextContentType? {
        switch self {
        case .username:
            return .username
        case .password,
             .passwordConfirmation:
            return .newPassword
        case .email:
            return .emailAddress
        case .address:
            return .fullStreetAddress
        case .birthDate:
            return .dateTime
        case .givenName:
            return .givenName
        case .middleName:
            return .middleName
        case .familyName:
            return .familyName
        case .name:
            return .name
        case .nickname:
            return .nickname
        case .gender:
            return nil
        case .phoneNumber:
            return .telephoneNumber
        case .preferredUsername:
            return .username
        case .profile:
            return nil
        case .website:
            return .URL
#if canImport(UIKit)
        case .custom(_, let textContentType):
            return textContentType
#else
        case .custom(_):
            return nil
#endif
        }
    }
#endif

}

extension CognitoConfiguration.VerificationMechanism {
    var asSignUpAttribute: SignUpAttribute {
        switch self {
        case .email:
            return .email
        case .phoneNumber:
            return .phoneNumber
        }
    }
}

extension CognitoConfiguration.SignUpAttribute {
    var asSignUpAttribute: SignUpAttribute {
        switch self {
        case .email:
            return .email
        case .phoneNumber:
            return .phoneNumber
        case .address:
            return .address
        case .birthDate:
            return .birthDate
        case .familyName:
            return .familyName
        case .gender:
            return .gender
        case .givenName:
            return .givenName
        case .middleName:
            return .middleName
        case .name:
            return .name
        case .nickname:
            return .nickname
        case .preferredUsername:
            return .preferredUsername
        case .profile:
            return .profile
        case .website:
            return .website
        }
    }
}
