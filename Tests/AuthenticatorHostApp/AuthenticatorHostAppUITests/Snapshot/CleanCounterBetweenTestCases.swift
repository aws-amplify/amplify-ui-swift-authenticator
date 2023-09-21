//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest

let counterQueue = DispatchQueue(label: "com.amplify.authenticator.counter")
var counterMap: [URL: Int] = [:]

// We need to clean counter between tests executions in order to support test-iterations.
class CleanCounterBetweenTestCases: NSObject, XCTestObservation {
    private static var registered = false
    private static var registerQueue = DispatchQueue(
        label: "com.amplify.authenticator.testObserver")

    static func registerIfNeeded() {
        registerQueue.sync {
            if !registered {
                registered = true
                XCTestObservationCenter.shared.addTestObserver(CleanCounterBetweenTestCases())
            }
        }
    }

    func testCaseDidFinish(_ testCase: XCTestCase) {
        counterQueue.sync {
            counterMap = [:]
        }
    }
}
