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
    case passwordlessFlow(Bool)
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
    case continueSignInWithMFASetupSelection
    case continueSignInWithEmailMFASetup
    case confirmSignInWithEmailMFACode
    case continueSignInWithFirstFactorSelection
    case confirmSignInWithOTP
    case confirmSignInWithPassword
    case resetPassword
    case confirmSignUp
    case done
}
