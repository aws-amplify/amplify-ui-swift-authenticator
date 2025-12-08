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
    
    func testSignUp_withEmailAsUsernameAttribute_shouldSetEmailAsUsername() async {
        authenticatorState.configuration.usernameAttributes = [.email]
        await state.configure(with: [.email()])

        let emailField = await state.fields.first(where: {$0.field.attributeType == .email})
        emailField?.value = "email@email.com"
        
        try? await state.signUp()
        XCTAssertEqual(authenticationService.signUpParams?.username, emailField?.value)
    }
    
    func testSignUp_withPhoneNumberAsUsernameAttribute_shouldSetPhoneAsUsername() async {
        authenticatorState.configuration.usernameAttributes = [.phoneNumber]
        await state.configure(with: [.phoneNumber()])

        let phoneNumberField = await state.fields.first(where: {$0.field.attributeType == .phoneNumber})
        phoneNumberField?.value = "+12345678910"
        
        try? await state.signUp()
        XCTAssertEqual(authenticationService.signUpParams?.username, phoneNumberField?.value)
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

        XCTAssertEqual(state.fields.count, 5) // 2 verification + 2 provided + 1 confirmPassword (auto-added for .password flow)
        XCTAssertTrue(state.fields.allSatisfy({ field in
            field.field.attributeType == .username ||
            field.field.attributeType == .password ||
            field.field.attributeType == .passwordConfirmation ||
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

        XCTAssertEqual(state.fields.count, 4) // username, password, confirmPassword (auto-added), email
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
    
    // MARK: - AuthenticationFlow Tests
    
    func testConfigure_withPasswordFlow_emptyFields_shouldIncludePasswordFields() {
        authenticatorState.authenticationFlow = .password
        state.configure(with: [])
        
        XCTAssertTrue(state.fields.contains(where: { $0.field.attributeType == .password && $0.field.isRequired }))
        XCTAssertTrue(state.fields.contains(where: { $0.field.attributeType == .passwordConfirmation && $0.field.isRequired }))
    }
    
    func testConfigure_withPasswordFlow_customFields_shouldAddPasswordFieldsAsRequired() {
        authenticatorState.authenticationFlow = .password
        state.configure(with: [
            .email(isRequired: true)
        ])
        
        XCTAssertTrue(state.fields.contains(where: { $0.field.attributeType == .password && $0.field.isRequired }))
        XCTAssertTrue(state.fields.contains(where: { $0.field.attributeType == .passwordConfirmation && $0.field.isRequired }))
    }
    
    func testConfigure_withPasswordFlow_customFields_shouldEnforcePasswordRequired() {
        authenticatorState.authenticationFlow = .password
        state.configure(with: [
            .email(isRequired: true),
            .password(isRequired: false), // Try to make it optional
            .confirmPassword(isRequired: false) // Try to make it optional
        ])
        
        // Password fields should be forced to required
        XCTAssertTrue(state.fields.contains(where: { $0.field.attributeType == .password && $0.field.isRequired }))
        XCTAssertTrue(state.fields.contains(where: { $0.field.attributeType == .passwordConfirmation && $0.field.isRequired }))
    }
    
    func testConfigure_withUserChoiceNoPreferred_emptyFields_shouldNotIncludePasswordFields() {
        authenticatorState.authenticationFlow = .userChoice()
        state.configure(with: [])
        
        XCTAssertFalse(state.fields.contains(where: { $0.field.attributeType == .password }))
        XCTAssertFalse(state.fields.contains(where: { $0.field.attributeType == .passwordConfirmation }))
    }
    
    func testConfigure_withUserChoiceNoPreferred_customFields_shouldNotAddPasswordFields() {
        authenticatorState.authenticationFlow = .userChoice()
        state.configure(with: [
            .email(isRequired: true)
        ])
        
        XCTAssertFalse(state.fields.contains(where: { $0.field.attributeType == .password }))
        XCTAssertFalse(state.fields.contains(where: { $0.field.attributeType == .passwordConfirmation }))
    }
    
    func testConfigure_withUserChoiceNoPreferred_customFieldsWithPassword_shouldAllowOptionalPassword() {
        authenticatorState.authenticationFlow = .userChoice()
        state.configure(with: [
            .email(isRequired: true),
            .password(isRequired: false),
            .confirmPassword(isRequired: false)
        ])
        
        // Password fields should remain optional
        XCTAssertTrue(state.fields.contains(where: { $0.field.attributeType == .password && !$0.field.isRequired }))
        XCTAssertTrue(state.fields.contains(where: { $0.field.attributeType == .passwordConfirmation && !$0.field.isRequired }))
    }
    
    func testConfigure_withUserChoicePasswordPreferred_emptyFields_shouldIncludeOptionalPasswordFields() {
        authenticatorState.authenticationFlow = .userChoice(preferredAuthFactor: .password())
        state.configure(with: [])
        
        XCTAssertTrue(state.fields.contains(where: { $0.field.attributeType == .password && !$0.field.isRequired }))
        XCTAssertTrue(state.fields.contains(where: { $0.field.attributeType == .passwordConfirmation && !$0.field.isRequired }))
    }
    
    func testConfigure_withUserChoicePasswordPreferred_customFields_shouldAddOptionalPasswordFields() {
        authenticatorState.authenticationFlow = .userChoice(preferredAuthFactor: .password(srp: true))
        state.configure(with: [
            .email(isRequired: true)
        ])
        
        XCTAssertTrue(state.fields.contains(where: { $0.field.attributeType == .password && !$0.field.isRequired }))
        XCTAssertTrue(state.fields.contains(where: { $0.field.attributeType == .passwordConfirmation && !$0.field.isRequired }))
    }
    
    func testConfigure_withUserChoiceWebAuthnPreferred_emptyFields_shouldNotIncludePasswordFields() {
        authenticatorState.authenticationFlow = .userChoice(preferredAuthFactor: .webAuthn)
        state.configure(with: [])
        
        XCTAssertFalse(state.fields.contains(where: { $0.field.attributeType == .password }))
        XCTAssertFalse(state.fields.contains(where: { $0.field.attributeType == .passwordConfirmation }))
    }
    
    func testConfigure_withUserChoiceEmailOtpPreferred_customFields_shouldNotAddPasswordFields() {
        authenticatorState.authenticationFlow = .userChoice(preferredAuthFactor: .emailOtp)
        state.configure(with: [
            .email(isRequired: true)
        ])
        
        XCTAssertFalse(state.fields.contains(where: { $0.field.attributeType == .password }))
        XCTAssertFalse(state.fields.contains(where: { $0.field.attributeType == .passwordConfirmation }))
    }
    
    func testConfigure_withUserChoiceSmsOtpPreferred_customFields_shouldNotAddPasswordFields() {
        authenticatorState.authenticationFlow = .userChoice(preferredAuthFactor: .smsOtp)
        state.configure(with: [
            .phoneNumber(isRequired: true)
        ])
        
        XCTAssertFalse(state.fields.contains(where: { $0.field.attributeType == .password }))
        XCTAssertFalse(state.fields.contains(where: { $0.field.attributeType == .passwordConfirmation }))
    }
    
    func testConfigure_withUsernameAlwaysAddedAndRequired() {
        authenticatorState.authenticationFlow = .userChoice()
        state.configure(with: [
            .email(isRequired: true)
        ])
        
        // Username should be automatically added and required
        XCTAssertTrue(state.fields.contains(where: { $0.field.attributeType == .username && $0.field.isRequired }))
    }
    
    func testConfigure_withUsernameInCustomFields_shouldEnforceRequired() {
        authenticatorState.authenticationFlow = .userChoice()
        state.configure(with: [
            .username(), // Already required by default
            .email(isRequired: true)
        ])
        
        // Username should remain required
        XCTAssertTrue(state.fields.contains(where: { $0.field.attributeType == .username && $0.field.isRequired }))
    }
}
