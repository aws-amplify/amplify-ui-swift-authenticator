//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest

final class ResetPasswordViewTests: AuthenticatorBaseTestCase {

    func testResetPasswordViewWithUsernameAsPhoneNumber() throws {
        launchApp(with: [
            .hidesSignUpButton(false),
            .initialStep(.resetPassword),
            .userAttributes([ .phoneNumber ])
        ])
        assertSnapshot()
    }
}
