//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import XCTest

class ContinueSignInWithMFASetupSelectionStateTests: XCTestCase {
    private var state: ContinueSignInWithMFASetupSelectionState!
    private var authenticatorState: MockAuthenticatorState!
    private var authenticationService: MockAuthenticationService!

    override func setUp() {
        authenticatorState = MockAuthenticatorState()
        state = ContinueSignInWithMFASetupSelectionState(
            authenticatorState: authenticatorState,
            allowedMFATypes: [.sms, .totp, .email])
        state.selectedMFATypeToSetup = MFAType.email

        authenticationService = MockAuthenticationService()
        authenticatorState.authenticationService = authenticationService
        state.configure(with: authenticatorState)
    }

    override func tearDown() {
        state = nil
        authenticatorState = nil
        authenticationService = nil
    }

    func testContinueSignIn_withSuccess_shouldSetNextStep() async throws {
        authenticationService.mockedConfirmSignInResult = .init(nextStep: .continueSignInWithMFASetupSelection([.sms, .totp, .email]))
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "username",
            userId: "userId"
        )

        try await state.continueSignIn()
        XCTAssertEqual(authenticationService.confirmSignInCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .continueSignInWithMFASetupSelection = currentStep else {
            XCTFail("Expected confirmSignInWithTOTPCode, was \(currentStep)")
            return
        }
    }

    func testContinueSignIn_withError_shouldSetErrorMessage() async throws {
        do {
            try await state.continueSignIn()
            XCTFail("Should not succeed")
        } catch {
            guard let authenticatorError = error as? AuthenticatorError else {
                XCTFail("Expected AuthenticatorError, was \(type(of: error))")
                return
            }

            let task = Task { @MainActor in
                XCTAssertNotNil(state.message)
                XCTAssertEqual(state.message?.content, authenticatorError.content)
            }
            await task.value
        }
    }

    func testContinueSignIn_withSuccess_andFailedToSignIn_shouldSetErrorMessage() async throws {
        authenticationService.mockedConfirmSignInResult = .init(nextStep: .done)
        do {
            try await state.continueSignIn()
            XCTFail("Should not succeed")
        } catch {
            XCTAssertEqual(authenticationService.confirmSignInCount, 1)
            guard let authenticatorError = error as? AuthenticatorError else {
                XCTFail("Expected AuthenticatorError, was \(type(of: error))")
                return
            }

            let task = Task { @MainActor in
                XCTAssertNotNil(state.message)
                XCTAssertEqual(state.message?.content, authenticatorError.content)
            }
            await task.value
        }
    }

    func testAllowedMFATypes_onContinueSignInWithMFACodeSelection_shouldReturnDetails() throws {

        authenticatorState.mockedStep = .continueSignInWithMFASelection(allowedMFATypes: [.sms, .totp, .email])

        let allowedMFATypes = try XCTUnwrap(state.allowedMFATypes)
        XCTAssertEqual(allowedMFATypes, [.sms, .totp, .email])
    }

}
