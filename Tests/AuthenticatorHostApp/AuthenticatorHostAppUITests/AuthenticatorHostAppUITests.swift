//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import UIKit

final class AuthenticatorHostAppUITests: XCTestCase {


    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // Launch Application
        XCUIApplication().launch()
        
    }

    override func tearDownWithError() throws {
        XCUIApplication().terminate()
    }

    func testSignInViewWithWithUsernameAsPhoneNumber() throws {
        assertSnapshot()
    }
}
