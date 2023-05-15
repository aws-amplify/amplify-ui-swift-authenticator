//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import Foundation

class MockAuthenticationService: AuthenticationService {

    // MARK: - Sign In

    var signInCount = 0
    var mockedSignInResult: AuthSignInResult?
    func signIn(username: String?, password: String?, options: AuthSignInRequest.Options?) async throws -> AuthSignInResult {
        signInCount += 1
        if let mockedSignInResult = mockedSignInResult {
            return mockedSignInResult
        }

        throw AuthenticatorError.error(message: "Unable to sign in")
    }

    var confirmSignInCount = 0
    var mockedConfirmSignInResult: AuthSignInResult?
    func confirmSignIn(challengeResponse: String, options: AuthConfirmSignInRequest.Options?) async throws -> AuthSignInResult {
        confirmSignInCount += 1
        if let mockedConfirmSignInResult = mockedConfirmSignInResult {
            return mockedConfirmSignInResult
        }

        throw AuthenticatorError.error(message: "Unable to confirm sign in")
    }

    var mockedCurrentUser: AuthUser?
    func getCurrentUser() async throws -> AuthUser {
        if let mockedCurrentUser = mockedCurrentUser {
            return mockedCurrentUser
        }

        throw AuthenticatorError.error(message: "Unable to retrieve Current User")
    }

    // MARK: - Reset Password

    var resetPasswordCount = 0
    var mockedResetPasswordResult: AuthResetPasswordResult?
    func resetPassword(for username: String, options: AuthResetPasswordRequest.Options?) async throws -> AuthResetPasswordResult {
        resetPasswordCount += 1
        if let mockedResetPasswordResult = mockedResetPasswordResult {
            return mockedResetPasswordResult
        }

        throw AuthenticatorError.error(message: "Unable to reset password")
    }

    var confirmResetPasswordCount = 0
    var mockedConfirmResetPasswordError: AuthenticatorError?
    func confirmResetPassword(for username: String, with newPassword: String, confirmationCode: String, options: AuthConfirmResetPasswordRequest.Options?) async throws {
        confirmResetPasswordCount += 1
        if let error = mockedConfirmResetPasswordError {
            throw error
        }
    }

    // MARK: - Sign Up

    var signUpCount = 0
    var signUpParams: (username: String, password: String?)? = nil
    var mockedSignUpResult: AuthSignUpResult?
    func signUp(username: String, password: String?, options: AuthSignUpRequest.Options?) async throws -> AuthSignUpResult {
        signUpCount += 1
        signUpParams = (username, password)
        
        if let mockedSignUpResult = mockedSignUpResult {
            return mockedSignUpResult
        }
        throw AuthenticatorError.error(message: "Unable to sign up")
    }

    var confirmSignUpCount = 0
    var mockedConfirmSignUpResult: AuthSignUpResult?
    func confirmSignUp(for username: String, confirmationCode: String, options: AuthConfirmSignUpRequest.Options?) async throws -> AuthSignUpResult {
        confirmSignUpCount += 1
        if let mockedConfirmSignUpResult = mockedConfirmSignUpResult {
            return mockedConfirmSignUpResult
        }

        throw AuthenticatorError.error(message: "Unable to confirm sign up")
    }

    var resendSignUpCodeCount = 0
    var mockedResendSignUpCodeResult: AuthCodeDeliveryDetails?
    func resendSignUpCode(for username: String, options: AuthResendSignUpCodeRequest.Options?) async throws -> AuthCodeDeliveryDetails {
        resendSignUpCodeCount += 1
        if let mockedResendSignUpCodeResult = mockedResendSignUpCodeResult {
            return mockedResendSignUpCodeResult
        }
        throw AuthenticatorError.error(message: "Unable to resend sign up code")
    }

    // MARK: - Verify User

    var fetchUserAttributesCount = 0
    var mockedUnverifiedAttributes: [AuthUserAttribute] = []
    func fetchUserAttributes(options: AuthFetchUserAttributesRequest.Options?) async throws -> [AuthUserAttribute] {
        fetchUserAttributesCount += 1
        return mockedUnverifiedAttributes
    }

    var resendConfirmationCodeForAttributeCount = 0
    var mockedResendConfirmationCodeForAttributeResult: AuthCodeDeliveryDetails?
    func resendConfirmationCode(forUserAttributeKey userAttributeKey: AuthUserAttributeKey, options: AuthAttributeResendConfirmationCodeRequest.Options?) async throws -> AuthCodeDeliveryDetails {
        resendConfirmationCodeForAttributeCount += 1
        if let mockedResendConfirmationCodeForAttributeResult = mockedResendConfirmationCodeForAttributeResult {
            return mockedResendConfirmationCodeForAttributeResult
        }

        throw AuthenticatorError.error(message: "Unable to resend confirmation code for attribute")
    }

    var confirmUserAttributeCount = 0
    var mockedConfirmUserAttributeError: AuthenticatorError?
    func confirm(userAttribute: AuthUserAttributeKey, confirmationCode: String, options: AuthConfirmUserAttributeRequest.Options?) async throws {
        confirmUserAttributeCount += 1
        if let mockedConfirmUserAttributeError = mockedConfirmUserAttributeError {
            throw mockedConfirmUserAttributeError
        }
    }

    // MARK: - Sign Out

    var signOutCount = 0
    var mockedSignOutResult: AuthSignOutResult?
    func signOut(options: AuthSignOutRequest.Options?) async -> AuthSignOutResult {
        signOutCount += 1
        return SignOutResult()
    }

    // MARK: - Web UI

    func signInWithWebUI(presentationAnchor: AuthUIPresentationAnchor?, options: AuthWebUISignInRequest.Options?) async throws -> AuthSignInResult {
        return .init(nextStep: .done)
    }

    func signInWithWebUI(for authProvider: AuthProvider, presentationAnchor: AuthUIPresentationAnchor?, options: AuthWebUISignInRequest.Options?) async throws -> AuthSignInResult {
        return .init(nextStep: .done)
    }

    // MARK: - User management

    func fetchAuthSession(options: AuthFetchSessionRequest.Options?) async throws -> AuthSession {
        return Session(isSignedIn: true)
    }

    func update(userAttribute: AuthUserAttribute, options: AuthUpdateUserAttributeRequest.Options?) async throws -> AuthUpdateAttributeResult {
        return .init(isUpdated: true, nextStep: .done)
    }

    func update(userAttributes: [AuthUserAttribute], options: AuthUpdateUserAttributesRequest.Options?) async throws -> [AuthUserAttributeKey: AuthUpdateAttributeResult] {
        return [:]
    }

    func update(oldPassword: String, to newPassword: String, options: AuthChangePasswordRequest.Options?) async throws {}

    func deleteUser() async throws {}

    // MARK: - Device management

    func fetchDevices(options: AuthFetchDevicesRequest.Options?) async throws -> [AuthDevice] {
        return []
    }

    func forgetDevice(_ device: AuthDevice?, options: AuthForgetDeviceRequest.Options?) async throws {}

    func rememberDevice(options: AuthRememberDeviceRequest.Options?) async throws {}
}

extension MockAuthenticationService {
    struct User: AuthUser {
        var username: String
        var userId: String
    }

    struct SignOutResult: AuthSignOutResult {}

    struct Session: AuthSession {
        var isSignedIn: Bool
    }
}
