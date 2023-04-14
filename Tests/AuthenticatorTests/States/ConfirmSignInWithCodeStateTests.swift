//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import XCTest

class ConfirmSignInWithCodeStateTests: XCTestCase {
    private var state: ConfirmSignInWithCodeState!
    private var authenticatorState: MockAuthenticatorState!
    private var authenticationService: MockAuthenticationService!

    override func setUp() {
        state = ConfirmSignInWithCodeState(credentials: Credentials())
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

    func testConfirmSignIn_withSuccess_shouldSetNextStep() async throws {
        authenticationService.mockedConfirmSignInResult = .init(nextStep: .done)
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "username",
            userId: "userId"
        )

        try await state.confirmSignIn()
        XCTAssertEqual(authenticationService.confirmSignInCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .signedIn(_) = currentStep else {
            XCTFail("Expected signedIn, was \(currentStep)")
            return
        }
    }

    func testConfirmSignIn_withError_shouldSetErrorMessage() async throws {
        do {
            try await state.confirmSignIn()
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

    func testConfirmSignIn_withSuccess_andFailedToSignIn_shouldSetErrorMessage() async throws {
        authenticationService.mockedConfirmSignInResult = .init(nextStep: .done)
        do {
            try await state.confirmSignIn()
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

    func testDeliveryDetails_onConfirmSignInWithMFACodeStep_shouldReturnDetails() throws {
        let destination = DeliveryDestination.sms("123456789")
        authenticatorState.mockedStep = .confirmSignInWithMFACode(deliveryDetails: .init(destination: destination))

        let deliveryDetails = try XCTUnwrap(state.deliveryDetails)
        XCTAssertEqual(deliveryDetails.destination, destination)
    }

    func testDeliveryDetails_onUnexpectedStep_shouldReturnNil() throws {
        let destination = DeliveryDestination.sms("123456789")
        authenticatorState.mockedStep = .confirmSignUp(deliveryDetails: .init(destination: destination))

        XCTAssertNil(state.deliveryDetails)
    }
}
