//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation

/// Represents the Authenticator's initial state for an unauthenticated ser
public struct AuthenticatorInitialStep: Equatable {
    private let name: String
    private init(_ name: String) {
        self.name = name
    }

    /// An unauthenticated user is presented with the Sign In view
    public static let signIn = AuthenticatorInitialStep("signIn")

    /// An unauthenticated user is presented with the Sign Up view
    public static let signUp = AuthenticatorInitialStep("signUp")

    /// An unauthenticated user is presented with the Reset Password view
    public static let resetPassword = AuthenticatorInitialStep("resetPassword")
}

/// An `AuthenticatorStep` represents a "state" or "view" for the Authenticator component within its lifecycle.
public struct AuthenticatorStep: Equatable {
    private let name: String
    //private(set) public var state: State = .signedOut

    private init(_ name: String) {
        self.name = name
    }

    /// The Authenticator is loading, i.e. fetching the current authentication status
    public static let loading = AuthenticatorStep("loading")

    /// There was an unrecoverable error
    public static let error = AuthenticatorStep("error")

    /// An unauthenticated user is presented with the Sing In view
    public static let signIn = AuthenticatorStep("signIn")

    /// A user has successfuly provided valid Sign In credentials but is required to provide an additional custom verification response,
    /// so they are presented with the Confirm Sign In with Custom Challenge view
    public static let confirmSignInWithCustomChallenge = AuthenticatorStep("confirmSignInWithCustomChallenge")

    /// A user has successfuly provided valid Sign In credentials but is required to provide a MFA code,
    /// so they are presented with the Confirm Sign In with MFA Code view
    public static let confirmSignInWithMFACode = AuthenticatorStep("confirmSignInWithMFACode")

    /// A user has sucessfuly provided valid Sign In credentials but is required to change their password,
    /// so they are presented with the Confirm Sign In with New Password view
    public static let confirmSignInWithNewPassword = AuthenticatorStep("confirmSignInWithNewPassword")

    /// An unauthenticated user is presented with the Sign Up view
    public static let signUp = AuthenticatorStep("signUp")

    /// An unauthenticated user has successfully created a new account and is required to confirm it,
    /// so they are presented with the Confirm Sign Up view
    public static let confirmSignUp = AuthenticatorStep("confirmSignUp")

    /// An unauthenticated user is presented with the Reset Password view
    public static let resetPassword = AuthenticatorStep("resetPassword")

    /// An unauthenticated user successfuly requested a Password Reset and they need to provide a verification code along their new password,
    /// so they are presented with the Confirm Reset Password view
    public static let confirmResetPassword = AuthenticatorStep("confirmResetPassword")

    /// A user has successfuly signed in but they have no verified attributes,
    /// so they are presented with the Verify User view
    public static let verifyUser = AuthenticatorStep("verifyUser")

    /// A user has successfuly requested to verify an attribute and they need to provide a verification code,
    /// so they are presented with the Confirm Verify User view
    public static let confirmVerifyUser = AuthenticatorStep("confirmVerifyUser")

    /// An authenticated user has successfuly signed in.
    public static let signedIn = AuthenticatorStep("signedIn")
}
