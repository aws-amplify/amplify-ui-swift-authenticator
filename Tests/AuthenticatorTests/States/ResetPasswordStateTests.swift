//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import XCTest

class ResetPasswordStateTests: XCTestCase {
    private var state: ResetPasswordState!
    private var authenticatorState: MockAuthenticatorState!
    private var authenticationService: MockAuthenticationService!

    override func setUp() {
        state = ResetPasswordState(credentials: Credentials())
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

    func testResetPassword_withConfirmReset_shouldSetNextStep() async throws {
        let destination = DeliveryDestination.sms("12345678")
        authenticationService.mockedResetPasswordResult = .init(
            isPasswordReset: false,
            nextStep: .confirmResetPasswordWithCode(.init(destination: destination), nil)
        )

        try await state.resetPassword()
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .confirmResetPassword(let deliveryDetails) = currentStep else {
            XCTFail("Expected confirmResetPassword, was \(currentStep)")
            return
        }
        XCTAssertEqual(deliveryDetails?.destination, destination)
    }

    func testResetPassword_withDone_shouldSetNextStep() async throws {
        authenticationService.mockedResetPasswordResult = .init(
            isPasswordReset: true,
            nextStep: .done
        )

        try await state.resetPassword()
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .signIn = currentStep else {
            XCTFail("Expected signIn, was \(currentStep)")
            return
        }
    }

    func testResetPassword_withFailure_shouldSetErrorMessage() async throws {
        do {
            try await state.resetPassword()
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
}
