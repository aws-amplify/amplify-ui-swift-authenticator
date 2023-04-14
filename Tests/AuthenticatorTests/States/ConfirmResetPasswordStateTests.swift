//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import XCTest

class ConfirmResetPasswordStateTests: XCTestCase {
    private var state: ConfirmResetPasswordState!
    private var authenticatorState: MockAuthenticatorState!
    private var authenticationService: MockAuthenticationService!

    override func setUp() {
        state = ConfirmResetPasswordState(credentials: Credentials())
        state.credentials.username = "username"
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

    func testConfirmResetPassword_withSuccess_andSignIn_shouldSetNextStep() async throws {
        authenticationService.mockedSignInResult = .init(nextStep: .done)
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "username",
            userId: "userId"
        )

        try await state.confirmResetPassword()
        XCTAssertEqual(authenticationService.confirmResetPasswordCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .signedIn(_) = currentStep else {
            XCTFail("Expected signedIn, was \(currentStep)")
            return
        }
    }

    func testConfirmResetPassword_withError_shouldSetErrorMessage() async throws {
        authenticationService.mockedConfirmResetPasswordError = .error(message: "Unable to confirm reset password")
        do {
            try await state.confirmResetPassword()
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

    func testConfirmResetPassword_withSuccess_andFailedToSignIn_shouldSetNextStep() async throws {
        try await state.confirmResetPassword()
        XCTAssertEqual(authenticationService.confirmResetPasswordCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .signIn = currentStep else {
            XCTFail("Expected signIn, was \(currentStep)")
            return
        }
    }

    func testDeliveryDetails_onConfirmResetPasswordStep_shouldReturnDetails() throws {
        let destination = DeliveryDestination.sms("123456789")
        authenticatorState.mockedStep = .confirmResetPassword(deliveryDetails: .init(destination: destination))

        let deliveryDetails = try XCTUnwrap(state.deliveryDetails)
        XCTAssertEqual(deliveryDetails.destination, destination)
    }

    func testDeliveryDetails_onUnexpectedStep_shouldRetunNil() throws {
        let destination = DeliveryDestination.sms("123456789")
        authenticatorState.mockedStep = .confirmSignUp(deliveryDetails: .init(destination: destination))

        XCTAssertNil(state.deliveryDetails)
    }
}
