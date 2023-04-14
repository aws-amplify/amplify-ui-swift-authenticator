//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import XCTest

class SignedInStateTests: XCTestCase {
    private var state: SignedInState!
    private var authenticationService: MockAuthenticationService!

    override func setUp() {
        authenticationService = MockAuthenticationService()
        state = SignedInState(
            user: MockAuthenticationService.User(username: "username", userId: "userId"),
            authenticationService: authenticationService
        )
    }

    override func tearDown() {
        state = nil
        authenticationService = nil
    }

    func testSignOut() async {
        let result = await state.signOut()
        XCTAssertEqual(authenticationService.signOutCount, 1)
        XCTAssertTrue(result is MockAuthenticationService.SignOutResult)
    }
}
