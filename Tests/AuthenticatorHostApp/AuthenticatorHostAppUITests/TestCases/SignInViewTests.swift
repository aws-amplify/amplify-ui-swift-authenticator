//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest

final class SignInViewTests: AuthenticatorBaseTestCase {

    func testSignInViewWithWithUsernameAsPhoneNumber() throws {
        launchApp(with: [
            .hidesSignUpButton(false),
            .initialStep(.signIn),
            .userAttributes([ .phoneNumber ])
        ])
        assertSnapshot()
    }

    func testSignInViewWithoutSignUp() throws {
        launchApp(with: [
            .hidesSignUpButton(true),
            .initialStep(.signIn),
            .userAttributes([ .phoneNumber ])
        ])
        assertSnapshot()
    }
}
