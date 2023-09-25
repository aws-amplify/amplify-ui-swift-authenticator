//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest

final class SignUpViewTests: AuthenticatorBaseTestCase {

    func testDefaultSignUpView() throws {
        launchApp(with: [
            .initialStep(.signUp),
        ])
        assertSnapshot()
    }
}
