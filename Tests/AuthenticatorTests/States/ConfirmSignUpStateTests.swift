//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import XCTest

class ConfirmSignUpStateTests: XCTestCase {
    private var state: ConfirmSignUpState!
    private var authenticatorState: MockAuthenticatorState!
    private var authenticationService: MockAuthenticationService!

    override func setUp() {
        state = ConfirmSignUpState(credentials: Credentials())
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

    func testConfirmSignUp_withSuccess_shouldSignIn_andSetNextStep() async throws {
        authenticationService.mockedConfirmSignUpResult = .init(.done)
        authenticationService.mockedSignInResult = .init(nextStep: .done)
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "username",
            userId: "userId"
        )

        try await state.confirmSignUp()
        XCTAssertEqual(authenticationService.confirmSignUpCount, 1)
        XCTAssertEqual(authenticationService.signInCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .signedIn(_) = currentStep else {
            XCTFail("Expected signedIn, was \(currentStep)")
            return
        }
    }

    func testConfirmSignUp_withError_shouldSetErrorMessage() async throws {
        do {
            try await state.confirmSignUp()
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

    func testConfirmSignUp_withSuccess_andFailedToSignIn_shouldSetNextStep() async throws {
        authenticationService.mockedConfirmSignUpResult = .init(.done)

        try await state.confirmSignUp()
        XCTAssertEqual(authenticationService.confirmSignUpCount, 1)
        XCTAssertEqual(authenticationService.signInCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .signIn = currentStep else {
            XCTFail("Expected signIn, was \(currentStep)")
            return
        }
    }

    func testSendCode_withSuccessAndDestination_shouldSetInfoMessage() async throws {
        let destination = DeliveryDestination.email("email@email.com")
        authenticationService.mockedResendSignUpCodeResult = .init(destination: destination)
        try await state.sendCode()
        let task = Task { @MainActor in
            XCTAssertNotNil(state.message)
            XCTAssertEqual(state.message?.style, .info)
            XCTAssertEqual(state.message?.content, "authenticator.banner.sendCode".localized(using: destination.value!))
        }
        await task.value
    }

    func testSendCode_withSuccessWithoutDestination_shouldSetInfoMessage() async throws {
        authenticationService.mockedResendSignUpCodeResult = .init(destination: .email(nil))
        try await state.sendCode()
        let task = Task { @MainActor in
            XCTAssertNotNil(state.message)
            XCTAssertEqual(state.message?.style, .info)
            XCTAssertEqual(state.message?.content, "authenticator.banner.sendCodeGeneric".localized())
        }
        await task.value
    }

    func testSendCode_withFailure_shouldSetErrorMessage() async throws {
        do {
            try await state.sendCode()
            XCTFail("Should not succeed")
        } catch {
            guard let authenticatorError = error as? AuthenticatorError else {
                XCTFail("Expected AuthenticatorError, was \(type(of: error))")
                return
            }

            let task = Task { @MainActor in
                XCTAssertNotNil(state.message)
                XCTAssertEqual(state.message?.style, .error)
                XCTAssertEqual(state.message?.content, authenticatorError.content)
            }
            await task.value
        }
    }

    func testDeliveryDetails_onConfirmSignUpStep_shouldReturnDetails() throws {
        let destination = DeliveryDestination.sms("123456789")
        authenticatorState.mockedStep = .confirmSignUp(deliveryDetails: .init(destination: destination))

        let deliveryDetails = try XCTUnwrap(state.deliveryDetails)
        XCTAssertEqual(deliveryDetails.destination, destination)
    }

    func testDeliveryDetails_onUnexpectedStep_shouldReturnNil() throws {
        let destination = DeliveryDestination.sms("123456789")
        authenticatorState.mockedStep = .confirmResetPassword(deliveryDetails: .init(destination: destination))

        XCTAssertNil(state.deliveryDetails)
    }
}
