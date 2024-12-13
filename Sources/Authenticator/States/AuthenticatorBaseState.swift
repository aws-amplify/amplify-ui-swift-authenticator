//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

/// The Base class for all State classes.
public class AuthenticatorBaseState: ObservableObject {
    /// Whether an operation is in progress
    @Published public var isBusy: Bool = false

    /// A message to be displayed
    @Published public var message: AuthenticatorMessage? = nil {
        didSet {
            credentials.message = nil
        }
    }

    @ObservedObject var credentials: Credentials

    var errorTransform: ((AuthError) -> AuthenticatorError?)? = nil
    private(set) var authenticatorState: AuthenticatorStateProtocol = .empty

    init(credentials: Credentials) {
        self.credentials = credentials
    }

    init(authenticatorState: AuthenticatorStateProtocol,
         credentials: Credentials) {
        self.authenticatorState = authenticatorState
        self.credentials = credentials
    }

    func configure(with authenticatorState: AuthenticatorStateProtocol) {
        self.authenticatorState = authenticatorState
    }

    var authenticationService: AuthenticationService {
        return authenticatorState.authenticationService
    }

    var configuration: CognitoConfiguration {
        return authenticatorState.configuration
    }

    func setBusy(_ isBusy: Bool) {
        DispatchQueue.main.async {
            self.isBusy = isBusy
            if isBusy {
                self.message = nil
            }
        }
    }

    func setMessage(_ message: AuthenticatorMessage) {
        DispatchQueue.main.async {
            self.isBusy = false
            self.message = message
        }
    }

    func nextStep(for result: AuthSignInResult) async throws -> Step {
        log.verbose("Sign In next step is \(result.nextStep)")
        switch result.nextStep {
        case .confirmSignInWithSMSMFACode(let details, _):
            return .confirmSignInWithMFACode(deliveryDetails: details)
        case .confirmSignInWithOTP(let details):
            return .confirmSignInWithOTP(deliveryDetails: details)
        case .confirmSignInWithCustomChallenge(_):
            return .confirmSignInWithCustomChallenge
        case .confirmSignInWithNewPassword(_):
            return .confirmSignInWithNewPassword
        case .resetPassword(_):
            return await nextStepForResetPassword()
        case .confirmSignUp(_):
            return .confirmSignUp(deliveryDetails: nil)
        case .done:
            let attributes = try await authenticationService.fetchUserAttributes(options: nil)
            var verifiedAttributes: [AuthUserAttributeKey] = []
            var unverifiedAttributes: [AuthUserAttributeKey] = []

            for attribute in attributes {
                guard attribute.key == .emailVerified || attribute.key == .phoneNumberVerified,
                      let isVerified = Bool(attribute.value) else {
                    continue
                }

                let verificationAttribute: AuthUserAttributeKey
                if attribute.key == .emailVerified {
                    verificationAttribute = .email
                } else {
                    verificationAttribute = .phoneNumber
                }

                if isVerified {
                    verifiedAttributes.append(verificationAttribute)
                } else {
                    unverifiedAttributes.append(verificationAttribute)
                }
            }

            if !verifiedAttributes.isEmpty || unverifiedAttributes.isEmpty {
                log.verbose("User is verified, moving to Signed In step")
                let user = try await authenticationService.getCurrentUser()
                return .signedIn(user: user)
            } else {
                log.verbose("User has attributes pending verification: \(unverifiedAttributes)")
                return .verifyUser(attributes: unverifiedAttributes)
            }
        case .confirmSignInWithTOTPCode:
            return .confirmSignInWithTOTPCode
        case .continueSignInWithMFASelection(let allowedMFATypes):
            return .continueSignInWithMFASelection(allowedMFATypes: allowedMFATypes)
        case .continueSignInWithTOTPSetup(let totpSetupDetails):
            return .continueSignInWithTOTPSetup(totpSetupDetails: totpSetupDetails)
        case .continueSignInWithMFASetupSelection(let allowedMFATypes):
            return .continueSignInWithMFASetupSelection(allowedMFATypes: allowedMFATypes)
        case .continueSignInWithEmailMFASetup:
            return .continueSignInWithEmailMFASetup
        default:
            throw AuthError.unknown("Unsupported next step: \(result.nextStep)", nil)
        }
    }

    func nextStep(for result: AuthSignUpResult) async throws -> Step {
        log.verbose("Sign Up next step is \(result.nextStep)")
        switch result.nextStep {
        case .confirmUser(let details, _, _):
            return .confirmSignUp(deliveryDetails: details)
        case .done:
            do {
                let signInResult = try await authenticationService.signIn(
                    username: credentials.username,
                    password: credentials.password,
                    options: nil
                )
                return try await nextStep(for: signInResult)
            } catch {
                // Unable to Sign In
                log.verbose("Unable to Sign In after sucessfull sign up")
                log.error(error)
                credentials.message = self.error(for: error)
                return .signIn
            }
        default:
            throw AuthError.unknown("Unsupported next step: \(result.nextStep)", nil)
        }
    }
    
    private func nextStepForResetPassword() async -> Step {
        do {
            let result = try await authenticationService.resetPassword(
                for: credentials.username,
                options: nil
            )

            log.verbose("Reset password next step is \(result.nextStep)")
            switch result.nextStep {
            case .confirmResetPasswordWithCode(let details, _):
                return .confirmResetPassword(deliveryDetails: details)
            case .done:
                log.warn("Received done next step after initiating a reset password. This is unexpected")
                // This should not happen, go back to Sign In screen
                return .signIn
            }
        } catch {
            log.verbose("Unable to initiate a password reset.")
            log.error(error)
            // Take the user to manually request a password reset
            return .resetPassword
        }
    }

    func localizedMessage(for details: AuthCodeDeliveryDetails?) -> String {
        guard let destination = details?.destination.value, !destination.isEmpty else {
            return "authenticator.banner.sendCodeGeneric".localized()
        }

        return "authenticator.banner.sendCode".localized(using: destination)
    }

    func error(for error: Error) -> AuthenticatorError {
        log.error(error)

        guard let authError = error as? AuthError else {
            return .unknown(from: error)
        }

        if let customError = errorTransform?(authError) {
            return customError
        }

        if let localizedMessage = localizedMessage(for: authError) {
            return .error(
                message: localizedMessage
            )
        }

        return .unknown(from: error)
    }

    private func localizedMessage(for error: AuthError) -> String? {
        if case .notAuthorized(let description, _, _) = error {
            switch description {
            case "Password attempts exceeded":
                return "authenticator.authError.passwordAttemptsExceeded".localized()
            default:
                return "authenticator.authError.incorrectCredentials".localized()
            }
        }

        if case .validation(let field, _, _, _) = error {
            switch authenticatorState.step {
            case .continueSignInWithMFASelection:
                if field.elementsEqual("challengeResponse") {
                    return "authenticator.authError.continueSignInWithMFASelection.noSelectionError".localized()
                }
                return nil
            default:
                return nil
            }
        }

        // First check if the underlying error is a connectivity one
        if error.isConnectivityError {
            log.verbose("The error is identified as a connectivity issue, displaying the corresponding localized string.")
            return "authenticator.cognitoError.network".localized()
        }

        guard let cognitoError = error.underlyingError as? AWSCognitoAuthError else {
            log.verbose("Unable to localize error that is not of type AWSCognitoAuthError")
            return nil
        }

        let key = "authenticator.cognitoError.\(cognitoError)"
        let localized = key.localized()

        if key != localized {
            log.verbose("A localizable string was found for error of type '\(cognitoError)'")
            return localized
        }
        
        log.verbose("No localizable string was found for error of type '\(cognitoError)'")
        return nil
    }
}

extension AuthenticatorBaseState: Equatable {
    public static func == (lhs: AuthenticatorBaseState, rhs: AuthenticatorBaseState) -> Bool {
        lhs === rhs
    }
}

extension AuthenticatorBaseState: AuthenticatorLogging {}
