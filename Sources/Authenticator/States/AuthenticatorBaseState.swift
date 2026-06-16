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
    
    /// Tracks if the current flow is from sign-up (for passkey prompt context)
    private var isFromSignUp: Bool = false

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
    
    var authenticationFlow: AuthenticationFlow {
        return authenticatorState.authenticationFlow
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
        case .confirmSignInWithPassword:
            return .signInConfirmPassword
        case .resetPassword(_):
            return await nextStepForResetPassword()
        case .confirmSignUp(_):
            return .confirmSignUp(deliveryDetails: nil)
        case .done:
            return try await nextStepAfterSignIn()
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
        case .continueSignInWithFirstFactorSelection(let availableFactors):
            // Translate Amplify AuthFactorType to Authenticator AuthFactor
            let authFactors = availableFactors.compactMap { factorType -> AuthFactor? in
                switch factorType {
                case .password:
                    return .password(srp: false)
                case .passwordSRP:
                    return .password(srp: true)
                case .smsOTP:
                    return .smsOtp
                case .emailOTP:
                    return .emailOtp
                #if os(iOS) || os(macOS) || os(visionOS)
                case .webAuthn:
                    if #available(iOS 17.4, macOS 13.5, visionOS 1.0, *) {
                        return .webAuthn
                    } else {
                        return nil
                    }
                #endif
                @unknown default:
                    log.verbose("Unknown auth factor type: \(factorType)")
                    return nil
                }
            }
            return .signInSelectAuthFactor(availableAuthFactors: authFactors)
        default:
            throw AuthError.unknown("Unsupported next step: \(result.nextStep)", nil)
        }
    }

    func nextStep(for result: AuthSignUpResult) async throws -> Step {
        log.verbose("Sign Up next step is \(result.nextStep)")
        switch result.nextStep {
        case .confirmUser(let details, _, _):
            return .confirmSignUp(deliveryDetails: details)
        case .completeAutoSignIn:
            do {
                log.verbose("Attempting auto sign-in after sign up")
                isFromSignUp = true
                let signInResult = try await authenticationService.autoSignIn()
                return try await nextStep(for: signInResult)
            } catch {
                // Unable to auto sign in
                log.verbose("Unable to auto sign-in after successful sign up")
                log.error(error)
                credentials.message = self.error(for: error)
                isFromSignUp = false
                return .signIn
            }
        case .done:
            do {
                isFromSignUp = true
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
                isFromSignUp = false
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
    
    /// Context for when the passkey prompt is being considered
    private enum PasskeyPromptContext {
        case signIn
        case signUp
    }
    
    /// Checks for unverified attributes and determines the next step
    /// - Returns: Either .verifyUser with unverified attributes or .signedIn
    func nextStepAfterPasskeyFlow() async throws -> Step {
        // Check for unverified attributes
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
    }
    
    /// Determines the next step after successful sign-in, handling passkey prompts first
    /// - Returns: The next step in the authentication flow
    func nextStepAfterSignIn() async throws -> Step {
        // Check if we should show passkey prompt before other post-sign-in steps
        let context: PasskeyPromptContext = isFromSignUp ? .signUp : .signIn
        let shouldShowPasskeyPrompt = await self.shouldShowPasskeyPrompt(context: context)
        
        // Reset the flag after checking
        isFromSignUp = false
        
        if shouldShowPasskeyPrompt {
            log.verbose("Showing passkey creation prompt")
            return .promptToCreatePasskey
        }
        
        // No passkey prompt needed, continue with attribute verification
        return try await nextStepAfterPasskeyFlow()
    }
    
    /// Checks if the passkey creation prompt should be shown
    /// - Parameter context: The context in which the prompt is being considered (signIn or signUp)
    /// - Returns: true if the prompt should be shown, false otherwise
    private func shouldShowPasskeyPrompt(context: PasskeyPromptContext) async -> Bool {
        // Check platform support first
        #if os(iOS) || os(macOS) || os(visionOS)
        // Check if platform version supports WebAuthn
        if #available(iOS 17.4, macOS 13.5, visionOS 1.0, *) {
            // Check PasskeyPrompts configuration from AuthenticationFlow
            guard case .userChoice(_, let passkeyPrompts) = authenticatorState.authenticationFlow else {
                log.verbose("AuthenticationFlow is not userChoice, skipping passkey prompt")
                return false
            }
            
            // Check if prompt is allowed based on context
            let promptSetting: PasskeyPrompt
            switch context {
            case .signIn:
                promptSetting = passkeyPrompts.afterSignIn
            case .signUp:
                promptSetting = passkeyPrompts.afterSignUp
            }
            
            guard promptSetting == .always else {
                log.verbose("Passkey prompt disabled by configuration (\(context): \(promptSetting))")
                return false
            }
            
            // Check if user already has a passkey
            do {
                let result = try await authenticationService.listWebAuthnCredentials(options: nil)
                if !result.credentials.isEmpty {
                    log.verbose("User already has passkeys, skipping prompt")
                    return false
                }
                
                // User has no passkeys, platform is supported, and prompt is enabled
                log.verbose("All conditions met, showing passkey prompt (context: \(context))")
                return true
            } catch {
                log.error("Failed to check existing passkeys: \(error)")
                return false
            }
        } else {
            log.verbose("Platform does not support WebAuthn")
            return false
        }
        #else
        log.verbose("WebAuthn not available on this platform")
        return false
        #endif
    }
}

extension AuthenticatorBaseState: Equatable, Hashable {
    public static func == (lhs: AuthenticatorBaseState, rhs: AuthenticatorBaseState) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher){
        hasher.combine(ObjectIdentifier(self))
    }
}

extension AuthenticatorBaseState: AuthenticatorLogging {}
