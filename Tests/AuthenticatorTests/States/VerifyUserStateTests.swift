//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import XCTest

class VerifyUserStateTests: XCTestCase {
    private var state: VerifyUserState!
    private var authenticatorState: MockAuthenticatorState!
    private var authenticationService: MockAuthenticationService!

    override func setUp() {
        state = VerifyUserState(credentials: Credentials())
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

    func testVerifyUser_withSuccess_shouldSetNextStep() async throws {
        let destination = DeliveryDestination.email("email@email.com")
        authenticationService.mockedSendVerificationCodeForAttributeResult = .init(destination: destination)
        let task = Task { @MainActor in
            state.selectedField = .email
        }
        await task.value
        try await state.verifyUser()
        XCTAssertEqual(authenticationService.sendVerificationCodeForAttributeCount, 1)
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .confirmVerifyUser(let attribute, let deliveryDetails) = currentStep else {
            XCTFail("Expected confirmVerifyUser, was \(currentStep)")
            return
        }

        XCTAssertEqual(attribute, .email)
        XCTAssertEqual(deliveryDetails?.destination, destination)
    }

    func testVerifyUser_withError_shouldSetErrorMessage() async throws {
        let task = Task { @MainActor in
            state.selectedField = .email
        }
        await task.value
        do {
            try await state.verifyUser()
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


    func testUnverifiedFields_onConfirmVerifyUserStep_shouldReturnAttributeKey() throws {
        let attributes: [AuthUserAttributeKey] = [
            .phoneNumber,
            .email
        ]
        authenticatorState.mockedStep = .verifyUser(attributes: attributes)
        let unverifiedFields = try XCTUnwrap(state.unverifiedFields)
        XCTAssertEqual(unverifiedFields, attributes)
    }

    func testUnverifiedFields_onUnexpectedStep_shouldReturnEmpty() throws {
        authenticatorState.mockedStep = .signIn
        XCTAssertTrue(state.unverifiedFields.isEmpty)
    }
}
