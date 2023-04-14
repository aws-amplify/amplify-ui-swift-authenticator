//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import XCTest

class ConfirmVerifyUserStateTests: XCTestCase {
    private var state: ConfirmVerifyUserState!
    private var authenticatorState: MockAuthenticatorState!
    private var authenticationService: MockAuthenticationService!

    override func setUp() {
        state = ConfirmVerifyUserState(credentials: Credentials())
        authenticatorState = MockAuthenticatorState()
        authenticatorState.mockedStep = .confirmVerifyUser(
            attribute: .email,
            deliveryDetails: nil
        )
        authenticationService = MockAuthenticationService()
        authenticatorState.authenticationService = authenticationService
        state.configure(with: authenticatorState)
    }

    override func tearDown() {
        state = nil
        authenticatorState = nil
        authenticationService = nil
    }

    func testConfirmVerifyUser_withSuccess_andSignIn_shouldSetNextStep() async throws {
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "username",
            userId: "userId"
        )

        try await state.confirmVerifyUser()
        XCTAssertEqual(authenticationService.confirmUserAttributeCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .signedIn(_) = currentStep else {
            XCTFail("Expected signedIn, was \(currentStep)")
            return
        }
    }

    func testConfirmVerifyUser_withError_shouldSetErrorMessage() async throws {
        authenticationService.mockedConfirmUserAttributeError = .error(message: "Unable to confirm attribute")
        do {
            try await state.confirmVerifyUser()
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

    func testSkip_withCurrentUser_shouldSetNextStep() async throws {
        try await state.skip()
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .signIn = currentStep else {
            XCTFail("Expected signIn, was \(currentStep)")
            return
        }
    }

    func testSkip_withoutCurrentUser_shouldSetNextStep() async throws {
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "username",
            userId: "userId"
        )
        try await state.skip()
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .signedIn(_) = currentStep else {
            XCTFail("Expected signedIn, was \(currentStep)")
            return
        }
    }

    func testDeliveryDetails_onConfirmVerifyUserStep_shouldReturnDetails() throws {
        let destination = DeliveryDestination.sms("123456789")
        authenticatorState.mockedStep = .confirmVerifyUser(attribute: .email, deliveryDetails: .init(destination: destination))

        let deliveryDetails = try XCTUnwrap(state.deliveryDetails)
        XCTAssertEqual(deliveryDetails.destination, destination)
    }

    func testDeliveryDetails_onUnexpectedStep_shouldReturnNil() throws {
        let destination = DeliveryDestination.sms("123456789")
        authenticatorState.mockedStep = .confirmSignUp(deliveryDetails: .init(destination: destination))

        XCTAssertNil(state.deliveryDetails)
    }

    func testUserAttributeKey_onConfirmVerifyUserStep_shouldReturnAttributeKey() throws {
        let attribute = AuthUserAttributeKey.phoneNumber
        authenticatorState.mockedStep = .confirmVerifyUser(attribute: attribute, deliveryDetails: nil)
        let userAttributeKey = try XCTUnwrap(state.userAttributeKey)
        XCTAssertEqual(userAttributeKey, attribute)
    }

    func testUserAttributeKey_onUnexpectedStep_shouldReturnNil() throws {
        authenticatorState.mockedStep = .resetPassword
        XCTAssertNil(state.userAttributeKey)
    }
}
