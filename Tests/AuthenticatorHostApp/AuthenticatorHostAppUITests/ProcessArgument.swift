//
//  ProcessArgument.swift
//  AuthenticatorHostApp
//
//  Created by Singh, Harshdeep on 2023-09-22.
//

import Foundation
@testable import Authenticator

enum ProcessArgument: Codable {
    case hidesSignUpButton(Bool)
    case initialStep(AuthenticatorInitialStep)
    case userAttributes([UserAttribute])
}

enum UserAttribute: String, Codable {
    case username = "USERNAME"
    case email = "EMAIL"
    case phoneNumber = "PHONE_NUMBER"
}
