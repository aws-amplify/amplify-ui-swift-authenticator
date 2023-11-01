//
//  ProcessArgument.swift
//  AuthenticatorHostApp
//
//  Created by Singh, Harshdeep on 2023-09-22.
//

import Foundation
@testable import Authenticator

let UITestKeyKey = "-uiTestArgsData"

enum ProcessArgument: Codable {
    case hidesSignUpButton(Bool)
    case initialStep(AuthenticatorInitialStep)
    case authSignInStep(AuthUITestSignInStep)
    case userAttributes([UserAttribute])
}

enum UserAttribute: String, Codable {
    case username = "USERNAME"
    case email = "EMAIL"
    case phoneNumber = "PHONE_NUMBER"
}

public enum AuthUITestSignInStep: Codable {
    case confirmSignInWithSMSMFACode
    case confirmSignInWithCustomChallenge
    case confirmSignInWithNewPassword
    case confirmSignInWithTOTPCode
    case continueSignInWithTOTPSetup
    case continueSignInWithMFASelection
    case resetPassword
    case confirmSignUp
    case done
}
