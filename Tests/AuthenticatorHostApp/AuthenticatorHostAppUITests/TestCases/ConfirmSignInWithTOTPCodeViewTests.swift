//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest

final class ConfirmSignInWithTOTPCodeViewTests: AuthenticatorBaseTestCase {

    func testConfirmSignInWithTOTPCodeView() throws {
        launchAppAndLogin(with: [
            .hidesSignUpButton(false),
            .initialStep(.signIn),
            .authSignInStep(.confirmSignInWithTOTPCode)
        ])
        assertSnapshot()
    }
}
