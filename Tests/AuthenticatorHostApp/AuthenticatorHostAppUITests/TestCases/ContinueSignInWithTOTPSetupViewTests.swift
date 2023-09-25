//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest

final class ContinueSignInWithTOTPSetupViewTests: AuthenticatorBaseTestCase {

    func testContinueSignInWithTOTPSetupView() throws {
        launchAppAndLogin(with: [
            .hidesSignUpButton(false),
            .initialStep(.signIn),
            .authSignInStep(.continueSignInWithTOTPSetup)
        ])
        assertSnapshot()
    }
}
