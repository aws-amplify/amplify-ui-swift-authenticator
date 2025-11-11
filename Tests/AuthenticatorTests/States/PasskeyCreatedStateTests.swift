//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import XCTest

class PasskeyCreatedStateTests: XCTestCase {
    private var state: PasskeyCreatedState!
    private var authenticatorState: MockAuthenticatorState!
    private var authenticationService: MockAuthenticationService!

    override func setUp() {
        state = PasskeyCreatedState(credentials: Credentials())
        authenticatorState = MockAuthenticatorState()
        authenticationService = MockAuthenticationService()
        authenticatorState.authenticationService = authenticationService
        state.configure(with: authenticatorState)
    }

    override func tearDown() {
        state = nil
        authenticatorState = nil
        authenticationService = nil
    }

    // TODO: Implement test for continue with success
    func testContinue_withSuccess_shouldTransitionToSignedIn() async throws {
        // TODO: Mock successful continuation
        // authenticationService.mockedCurrentUser = MockAuthenticationService.User(
        //     username: "username",
        //     userId: "userId"
        // )
        // try await state.continue()
        // XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        // let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        // guard case .signedIn(_) = currentStep else {
        //     XCTFail("Expected signedIn, was \(currentStep)")
        //     return
        // }
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }

    // TODO: Implement test for continue with error
    func testContinue_withError_shouldSetErrorMessage() async throws {
        // TODO: Mock error response
        // do {
        //     try await state.continue()
        //     XCTFail("Should not succeed")
        // } catch {
        //     guard let authenticatorError = error as? AuthenticatorError else {
        //         XCTFail("Expected AuthenticatorError")
        //         return
        //     }
        //     let task = Task { @MainActor in
        //         XCTAssertNotNil(state.message)
        //         XCTAssertEqual(state.message?.content, authenticatorError.content)
        //     }
        //     await task.value
        // }
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }

    // TODO: Implement test for passkey metadata
    func testPasskeyMetadata_shouldBeAvailable() {
        // TODO: Verify passkey creation metadata is accessible
        // - Creation timestamp
        // - Passkey ID
        // - Device information
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }

    // TODO: Implement test for multiple passkeys
    func testMultiplePasskeys_shouldBeSupported() {
        // TODO: Verify user can have multiple passkeys
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }
}
