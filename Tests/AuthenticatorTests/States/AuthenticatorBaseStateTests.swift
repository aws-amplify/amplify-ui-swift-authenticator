//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import AWSCognitoAuthPlugin
import XCTest

class AuthenticatorBaseStateTests: XCTestCase {
    private var state: AuthenticatorBaseState!
    private var authenticationService: MockAuthenticationService!

    override func setUp() {
        state = AuthenticatorBaseState(credentials: Credentials())
        let authenticatorState = AuthenticatorState()
        authenticationService = MockAuthenticationService()
        authenticatorState.authenticationService = authenticationService
        state.configure(with: authenticatorState)
    }

    override func tearDown() {
        state = nil
        authenticationService = nil
    }

    func testNextStep_forSignIn_withDone_andAllUnverifiedAttributes_shouldFetchUserAttributes() async throws {
        authenticationService.mockedUnverifiedAttributes = [
            .init(.phoneNumberVerified, value: "false"),
            .init(.emailVerified, value: "false")
        ]

        let result = AuthSignInResult(nextStep: .done)
        let nextStep = try await state.nextStep(for: result)
        XCTAssertEqual(authenticationService.fetchUserAttributesCount, 1)
        guard case .verifyUser(let attributes) = nextStep else {
            XCTFail("Expected next step to be verifyUser,was \(nextStep)")
            return
        }
        XCTAssertEqual(attributes.count, 2)
        XCTAssertTrue(attributes.contains(where: { $0 == .email || $0 == .phoneNumber }))
    }

    func testNextStep_forSignIn_withDone_andSomeUnverifiedAttributes_shouldFetchUserAttributes() async throws {
        authenticationService.mockedUnverifiedAttributes = [
            .init(.phoneNumberVerified, value: "false"),
            .init(.emailVerified, value: "true")
        ]
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "username",
            userId: "userId"
        )

        let result = AuthSignInResult(nextStep: .done)
        let nextStep = try await state.nextStep(for: result)
        XCTAssertEqual(authenticationService.fetchUserAttributesCount, 1)
        guard case .signedIn(let user) = nextStep else {
            XCTFail("Expected next step to be signedIn, was \(nextStep)")
            return
        }
        XCTAssertEqual(user.username, "username")
        XCTAssertEqual(user.userId, "userId")
    }

    func testNextStep_forSignIn_withDone_andAllVerifiedAttributes_shouldFetchUserAttributes() async throws {
        authenticationService.mockedUnverifiedAttributes = [
            .init(.phoneNumberVerified, value: "true"),
            .init(.emailVerified, value: "true")
        ]
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "username",
            userId: "userId"
        )

        let result = AuthSignInResult(nextStep: .done)
        let nextStep = try await state.nextStep(for: result)
        XCTAssertEqual(authenticationService.fetchUserAttributesCount, 1)
        guard case .signedIn(let user) = nextStep else {
            XCTFail("Expected next step to be signedIn, was \(nextStep)")
            return
        }
        XCTAssertEqual(user.username, "username")
        XCTAssertEqual(user.userId, "userId")
    }

    func testNextStep_forSignIn_withConfirmSignInWithSMSMFACode_shouldReturnConfirmSignInWithMFACode() async throws {
        let destination = DeliveryDestination.email("email@email.com")
        let result = AuthSignInResult(
            nextStep: .confirmSignInWithSMSMFACode(
                .init(destination: destination),
                nil
            )
        )
        let nextStep = try await state.nextStep(for: result)
        guard case .confirmSignInWithMFACode(let deliveryDetails) = nextStep else {
            XCTFail("Expected next step to be confirmSignInWithMFACode, was \(nextStep)")
            return
        }
        XCTAssertNotNil(deliveryDetails)
        XCTAssertEqual(deliveryDetails?.destination, destination)
    }

    func testNextStep_forSignIn_withConfirmSignInWithCustomChallenge_shouldReturnConfirmSignInWithCustomChallenge() async throws {
        let result = AuthSignInResult(nextStep: .confirmSignInWithCustomChallenge(nil))
        let nextStep = try await state.nextStep(for: result)
        guard case .confirmSignInWithCustomChallenge = nextStep else {
            XCTFail("Expected next step to be confirmSignInWithCustomChallenge, was \(nextStep)")
            return
        }
    }

    func testNextStep_forSignIn_withConfirmSignInWithNewPassword_shouldReturnConfirmSignInWithNewPassword() async throws {
        let result = AuthSignInResult(nextStep: .confirmSignInWithNewPassword(nil))
        let nextStep = try await state.nextStep(for: result)
        guard case .confirmSignInWithNewPassword = nextStep else {
            XCTFail("Expected next step to be confirmSignInWithNewPassword, was \(nextStep)")
            return
        }
    }

    func testNextStep_forSignIn_withConfirmSignUp_shouldReturnConfirmSignUp() async throws {
        let result = AuthSignInResult(nextStep: .confirmSignUp(nil))
        let nextStep = try await state.nextStep(for: result)
        guard case .confirmSignUp(let deliveryDetails) = nextStep else {
            XCTFail("Expected next step to be confirmSignUp, was \(nextStep)")
            return
        }
        XCTAssertNil(deliveryDetails)
    }

    func testNextStep_forSignIn_withResetPassword_andConfirmResetPassword_shouldCallResetPassword_andReturnConfirmResetPassword() async throws {
        let destination = DeliveryDestination.email("email@email.com")
        let signInResult = AuthSignInResult(nextStep: .resetPassword(nil))
        authenticationService.mockedResetPasswordResult = AuthResetPasswordResult(
            isPasswordReset: false,
            nextStep: .confirmResetPasswordWithCode(
                .init(destination: destination),
                nil
            )
        )
        let nextStep = try await state.nextStep(for: signInResult)
        XCTAssertEqual(authenticationService.resetPasswordCount, 1)
        guard case .confirmResetPassword(let deliveryDetails) = nextStep else {
            XCTFail("Expected next step to be confirmResetPassword, was \(nextStep)")
            return
        }
        XCTAssertNotNil(deliveryDetails)
        XCTAssertEqual(deliveryDetails?.destination, destination)
    }

    func testNextStep_forSignIn_withResetPassword_andDone_shouldCallResetPassword_andReturnSignIn() async throws {
        let signInResult = AuthSignInResult(nextStep: .resetPassword(nil))
        authenticationService.mockedResetPasswordResult = AuthResetPasswordResult(
            isPasswordReset: true,
            nextStep: .done
        )
        let nextStep = try await state.nextStep(for: signInResult)
        XCTAssertEqual(authenticationService.resetPasswordCount, 1)
        guard case .signIn = nextStep else {
            XCTFail("Expected next step to be signIn, was \(nextStep)")
            return
        }
    }

    func testNextStep_forSignIn_withResetPassword_andUnableToResetPassword_shouldReturnResetPassword() async throws {
        let signInResult = AuthSignInResult(nextStep: .resetPassword(nil))
        authenticationService.mockedResetPasswordResult = nil
        let nextStep = try await state.nextStep(for: signInResult)
        XCTAssertEqual(authenticationService.resetPasswordCount, 1)
        guard case .resetPassword = nextStep else {
            XCTFail("Expected next step to be resetPassword, was \(nextStep)")
            return
        }
    }

    func testNextStep_forSignUp_withConfirmSignUp_shouldReturnConfirmSignUp() async throws {
        let destination = DeliveryDestination.email("email@email.com")
        let result = AuthSignUpResult(.confirmUser(.init(destination: destination)))
        let nextStep = try await state.nextStep(for: result)
        guard case .confirmSignUp(let deliveryDetails) = nextStep else {
            XCTFail("Expected next step to be confirmSignUp, was \(nextStep)")
            return
        }
        XCTAssertNotNil(deliveryDetails)
        XCTAssertEqual(deliveryDetails?.destination, destination)
    }

    func testNextStep_forSignUp_withDone_shouldCallSignIn_andReturnNextStep() async throws {
        authenticationService.mockedSignInResult = AuthSignInResult(nextStep: .done)
        authenticationService.mockedCurrentUser = MockAuthenticationService.User(
            username: "username",
            userId: "userId"
        )

        let signUpResult = AuthSignUpResult(.done)
        let nextStep = try await state.nextStep(for: signUpResult)
        guard case .signedIn(let user) = nextStep else {
            XCTFail("Expected next step to be signedIn, was \(nextStep)")
            return
        }
        XCTAssertEqual(user.username, "username")
        XCTAssertEqual(user.userId, "userId")
    }

    func testNextStep_forSignUp_withDone_andUnableToSignIn_shouldReturnSignIn() async throws {
        let result = AuthSignUpResult(.done)
        let nextStep = try await state.nextStep(for: result)
        guard case .signIn = nextStep else {
            XCTFail("Expected next step to be signedIn, was \(nextStep)")
            return
        }
    }

    func testError_forNotAuthError_shouldReturnUnknownError() {
        let error: Error = NSError(domain: "Authenticator", code: 100)
        let authenticatorError = state.error(for: error)
        XCTAssertEqual(authenticatorError.style, .error)
        XCTAssertEqual(authenticatorError.content, "authenticator.unknownError".localized())
    }

    func testError_withNotAuthorizedError_shouldReturnLocalizedError() {
        let authenticatorError = state.error(for: AuthError.notAuthorized("description", "recovery", nil))
        XCTAssertEqual(authenticatorError.style, .error)
        XCTAssertEqual(authenticatorError.content, "authenticator.authError.incorrectCredentials".localized())
    }

    func testError_withCustomErrorTransform_shouldReturnCustomError() {
        var closureCount = 0
        state.errorTransform = { error in
            closureCount = 1
            return .error(message: "A custom error")
        }
        let authenticatorError = state.error(for: AuthError.notAuthorized("description", "recovery", nil))
        XCTAssertEqual(closureCount, 1)
        XCTAssertEqual(authenticatorError.style, .error)
        XCTAssertEqual(authenticatorError.content, "A custom error")
    }

    func testError_withCustomErrorTransformThatReturnsNil_shouldReturnDefaultError() {
        var closureCount = 0
        state.errorTransform = { error in
            closureCount = 1
            if case .service = error {
                return .error(message: "A service error")
            }
            return nil
        }
        let authenticatorError = state.error(for: AuthError.notAuthorized("description", "recovery", nil))
        XCTAssertEqual(closureCount, 1)
        XCTAssertEqual(authenticatorError.style, .error)
        let expectedMessage = "authenticator.authError.incorrectCredentials".localized()
        XCTAssertEqual(authenticatorError.content, expectedMessage)
    }

    func testError_withLocalizedCognitoError_shouldReturnLocalizedError() {
        let cognitoError = AWSCognitoAuthError.userNotFound
        let authenticatorError = state.error(for: AuthError.service("description", "recovery", cognitoError))
        XCTAssertEqual(authenticatorError.style, .error)
        XCTAssertEqual(authenticatorError.content, "authenticator.cognitoError.userNotFound".localized())
    }

    func testError_withNotLocalizedCognitoError_shouldReturnUnknownError() {
        let cognitoError = AWSCognitoAuthError.deviceNotTracked
        let authenticatorError = state.error(for: AuthError.service("description", "recovery", cognitoError))
        XCTAssertEqual(authenticatorError.style, .error)
        XCTAssertEqual(authenticatorError.content, "authenticator.unknownError".localized())
    }
}

