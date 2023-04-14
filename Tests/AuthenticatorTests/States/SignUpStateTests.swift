//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import XCTest

class SignUpStateTests: XCTestCase {
    private var state: SignUpState!
    private var authenticatorState: MockAuthenticatorState!
    private var authenticationService: MockAuthenticationService!

    override func setUp() {
        state = SignUpState(credentials: Credentials())
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

    func testSignUp_withSuccess_shouldSetNextStep() async throws {
        authenticationService.mockedSignUpResult = .init(.done)
        authenticationService.mockedSignInResult = .init(nextStep: .done)
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "username",
            userId: "userId"
        )

        try await state.signUp()
        XCTAssertEqual(authenticatorState.setCurrentStepCount, 1)
        let currentStep = try XCTUnwrap(authenticatorState.setCurrentStepValue)
        guard case .signedIn(_) = currentStep else {
            XCTFail("Expected signedIn, was \(currentStep)")
            return
        }
    }

    func testSignUp_withFailure_shouldSetErrorMessage() async throws {
        do {
            try await state.signUp()
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

    func testConfigure_withFields_shouldPopulateFields_addingVerificationMechanism() {
        authenticatorState.configuration.verificationMechanisms = [
            .email,
            .phoneNumber
        ]
        state.configure(with: [
            .username(),
            .password()
        ])

        XCTAssertEqual(state.fields.count, 4) // 2 verification + 2 provided
        XCTAssertTrue(state.fields.allSatisfy({ field in
            field.field.attributeType == .username ||
            field.field.attributeType == .password ||
            (field.field.attributeType == .phoneNumber && field.field.isRequired) ||
            (field.field.attributeType == .email && field.field.isRequired)
        }))
    }

    func testConfigure_withFields_shouldPopulateFields_addingMarkVerificationMechanismAsRequired() {
        authenticatorState.configuration.verificationMechanisms = [
            .email,
        ]
        state.configure(with: [
            .username(),
            .password(),
            .email(isRequired: false)
        ])

        XCTAssertEqual(state.fields.count, 3)
        XCTAssertTrue(state.fields.contains(where: { field in
            field.field.attributeType == .email && field.field.isRequired
        }))
    }

    func testConfigure_withEmptyFields_shouldReadFromConfiguration() {
        authenticatorState.configuration.signupAttributes = [
            .address,
            .nickname
        ]
        authenticatorState.configuration.verificationMechanisms = [
            .phoneNumber
        ]
        state.configure(with: [])
        XCTAssertEqual(state.fields.count, 6) // username, password, confirm password by default + 3 from configuration
        XCTAssertTrue(state.fields.allSatisfy({ field in
            field.field.attributeType == .username ||
            field.field.attributeType == .password ||
            field.field.attributeType == .passwordConfirmation ||
            field.field.attributeType == .address ||
            field.field.attributeType == .nickname ||
            (field.field.attributeType == .phoneNumber && field.field.isRequired)
        }))
    }

    func testConfigure_withEmptyFields_usingEmailLogin_shouldReadFromConfiguration() {
        authenticatorState.configuration.usernameAttributes = [
            .email
        ]
        authenticatorState.configuration.verificationMechanisms = [
            .phoneNumber
        ]
        state.configure(with: [])
        XCTAssertEqual(state.fields.count, 4) // email, password, confirm password by default + 1 from configuration
        XCTAssertTrue(state.fields.allSatisfy({ field in
            field.field.attributeType == .email ||
            field.field.attributeType == .password ||
            field.field.attributeType == .passwordConfirmation ||
            (field.field.attributeType == .phoneNumber && field.field.isRequired)
        }))
    }
}
