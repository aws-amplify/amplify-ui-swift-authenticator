//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation

enum Step {
    case loading
    case error(_ error: Error)
    case signIn
    case confirmSignInWithCustomChallenge
    case confirmSignInWithTOTPCode
    case continueSignInWithMFASelection(allowedMFATypes: AllowedMFATypes)
    case continueSignInWithMFASetupSelection(allowedMFATypes: AllowedMFATypes)
    case continueSignInWithEmailMFASetup
    case continueSignInWithTOTPSetup(totpSetupDetails: TOTPSetupDetails)
    case confirmSignInWithMFACode(deliveryDetails: AuthCodeDeliveryDetails?)
    case confirmSignInWithNewPassword
    case signUp
    case confirmSignUp(deliveryDetails: AuthCodeDeliveryDetails?)
    case resetPassword
    case confirmResetPassword(deliveryDetails: AuthCodeDeliveryDetails?)
    case verifyUser(attributes: [AuthUserAttributeKey])
    case confirmVerifyUser(attribute: AuthUserAttributeKey, deliveryDetails: AuthCodeDeliveryDetails?)
    case signedIn(user: AuthUser)

    init(from initialStep: AuthenticatorInitialStep) {
        switch initialStep {
        case .signIn:
            self = .signIn
        case .signUp:
            self = .signUp
        case .resetPassword:
            self = .resetPassword
        default:
            self = .signIn
        }
    }

    var authenticatorStep: AuthenticatorStep {
        switch self {
        case .loading:
            return .loading
        case .error:
            return .error
        case .signIn:
            return .signIn
        case .confirmSignInWithCustomChallenge:
            return .confirmSignInWithCustomChallenge
        case .confirmSignInWithTOTPCode:
            return .confirmSignInWithTOTPCode
        case .continueSignInWithTOTPSetup:
            return .continueSignInWithTOTPSetup
        case .continueSignInWithMFASelection:
            return .continueSignInWithMFASelection
        case .continueSignInWithMFASetupSelection:
            return .continueSignInWithMFASetupSelection
        case .continueSignInWithEmailMFASetup:
            return .continueSignInWithEmailMFASetup
        case .confirmSignInWithMFACode:
            return .confirmSignInWithMFACode
        case .confirmSignInWithNewPassword:
            return .confirmSignInWithNewPassword
        case .signUp:
            return .signUp
        case .confirmSignUp:
            return .confirmSignUp
        case .resetPassword:
            return .resetPassword
        case .confirmResetPassword:
            return .confirmResetPassword
        case .signedIn(_):
            return .signedIn
        case .verifyUser:
            return .verifyUser
        case .confirmVerifyUser:
            return .confirmVerifyUser
        }
    }
}

extension Step: Equatable {
    public static func == (lhs: Step, rhs: Step) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
             (.error, .error),
             (.signIn, .signIn),
             (.continueSignInWithMFASelection, .continueSignInWithMFASelection),
             (.confirmSignInWithTOTPCode, .confirmSignInWithTOTPCode),
             (.continueSignInWithTOTPSetup, .continueSignInWithTOTPSetup),
             (.confirmSignInWithCustomChallenge, .confirmSignInWithCustomChallenge),
             (.confirmSignInWithNewPassword, .confirmSignInWithNewPassword),
             (.signUp, .signUp),
             (.resetPassword, .resetPassword):
            return true
        case (.confirmSignInWithMFACode(let lDetails), .confirmSignInWithMFACode(let hDetails)),
             (.confirmSignUp(let lDetails), .confirmSignUp(let hDetails)),
             (.confirmResetPassword(let lDetails), .confirmResetPassword(let hDetails)):
            return lDetails == hDetails
        case (.verifyUser(let lAttributes), .verifyUser(let rAttributes)):
            return lAttributes == rAttributes
        case (.confirmVerifyUser(let lAttributes, let lDetails), .confirmVerifyUser(let rAttributes, let rDetails)):
            return lAttributes == rAttributes && lDetails == rDetails
        case (.signedIn(let lUser), .signedIn(let rUser)):
            return lUser.username == rUser.username && lUser.userId == rUser.userId
        default:
            return false
        }
    }
}
