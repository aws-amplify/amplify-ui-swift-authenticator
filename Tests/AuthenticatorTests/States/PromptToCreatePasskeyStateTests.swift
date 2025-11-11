//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import XCTest

class PromptToCreatePasskeyStateTests: XCTestCase {
    private var state: PromptToCreatePasskeyState!
    private var authenticatorState: MockAuthenticatorState!
    private var authenticationService: MockAuthenticationService!

    override func setUp() {
        state = PromptToCreatePasskeyState(credentials: Credentials())
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

    // TODO: Implement test for createPasskey with success
    func testCreatePasskey_withSuccess_shouldTransitionToPasskeyCreated() async throws {
        // TODO: Mock successful passkey creation
        // authenticationService.mockedCreatePasskeyResult = .success
        // try await state.createPasskey()
        // XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        // let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        // guard case .passkeyCreated = currentStep else {
        //     XCTFail("Expected passkeyCreated, was \(currentStep)")
        //     return
        // }
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }

    // TODO: Implement test for createPasskey with error
    func testCreatePasskey_withError_shouldSetErrorMessage() async throws {
        // TODO: Mock error response
        // do {
        //     try await state.createPasskey()
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

    // TODO: Implement test for createPasskey with user cancellation
    func testCreatePasskey_withUserCancellation_shouldHandleGracefully() async throws {
        // TODO: Mock user cancellation
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }

    // TODO: Implement test for skip with success
    func testSkip_withSuccess_shouldTransitionToSignedIn() async throws {
        // TODO: Mock successful skip
        // authenticationService.mockedCurrentUser = MockAuthenticationService.User(
        //     username: "username",
        //     userId: "userId"
        // )
        // try await state.skip()
        // XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        // let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        // guard case .signedIn(_) = currentStep else {
        //     XCTFail("Expected signedIn, was \(currentStep)")
        //     return
        // }
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }

    // TODO: Implement test for skip with error
    func testSkip_withError_shouldSetErrorMessage() async throws {
        // TODO: Mock error response
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }

    // TODO: Implement test for passkey prompt configuration
    func testPasskeyPromptConfiguration_shouldRespectSettings() {
        // TODO: Test different PasskeyPrompts configurations
        // - .always
        // - .afterSignUp
        // - .never
        XCTExpectFailure("Test not yet implemented")
        XCTFail("Test not yet implemented")
    }
}
