//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

@testable import Amplify
@testable import Authenticator
import AWSCognitoAuthPlugin
import SwiftUI

enum SignInNextStepForTesting: String, CaseIterable, Identifiable {
    case done = "Done"
    case continueSignInWithMFASelection = "Continue with MFA Selection"
    case continueSignInWithEmailMFASetup = "Continue with Email MFA Setup"
    case continueSignInWithMFASetupSelection = "Continue with MFA Setup Selection"
    case confirmSignInWithEmailMFACode = "Confirm with Email MFA Code"
    case confirmSignInWithPhoneMFACode = "Confirm with Phone MFA Code"
    case confirmSignInWithTOTP = "Confirm with TOTP"
    case customAuth = "Confirm sign in with Custom Auth"
    case continueSignInWithFirstFactorSelection = "Sign In Select Auth Factor"
    case confirmSignInWithOTP = "Confirm Sign In with OTP"
    case confirmSignInWithPassword = "Confirm Sign In with Password"

    var id: String { self.rawValue }
    
    func toAuthSignInStep() -> AuthSignInStep {
        switch self {
        case .done:
            return .done
        case .continueSignInWithMFASelection:
            return .continueSignInWithMFASelection(.init([.sms, .email, .totp]))
        case .continueSignInWithEmailMFASetup:
            return .continueSignInWithEmailMFASetup
        case .continueSignInWithMFASetupSelection:
            return .continueSignInWithMFASetupSelection(.init([.email, .totp]))
        case .confirmSignInWithEmailMFACode:
            return .confirmSignInWithOTP(.init(destination: .email("h***@a***.com")))
        case .confirmSignInWithPhoneMFACode:
            return .confirmSignInWithOTP(.init(destination: .phone("+11***")))
        case .confirmSignInWithTOTP:
            return .confirmSignInWithTOTPCode
        case .customAuth:
            return .confirmSignInWithCustomChallenge(nil)
        case .continueSignInWithFirstFactorSelection:
            // WebAuthn is only available in iOS 17.4+, macOS 13.5+, visionOS 1.0+
            var availableFactors: Set<AuthFactorType> = [.emailOTP, .smsOTP, .password, .passwordSRP]
            #if os(iOS) || os(macOS) || os(visionOS)
            if #available(iOS 17.4, macOS 13.5, visionOS 1.0, *) {
                availableFactors.insert(.webAuthn)
            }
            #endif
            return .continueSignInWithFirstFactorSelection(availableFactors)
        case .confirmSignInWithOTP:
            return .confirmSignInWithOTP(.init(destination: .email("tst@example.com")))
        case .confirmSignInWithPassword:
            return .confirmSignInWithPassword
        }
    }
}

enum ConfirmSignInNextStepForTesting: String, CaseIterable, Identifiable {
    case done = "Done"
    case continueSignInWithMFASelection = "Continue with MFA Selection"
    case continueSignInWithEmailMFASetup = "Continue with Email MFA Setup"
    case continueSignInWithMFASetupSelection = "Continue with MFA Setup Selection"
    case confirmSignInWithEmailMFACode = "Confirm with Email MFA Code"
    case confirmSignInWithPhoneMFACode = "Confirm with Phone MFA Code"
    case confirmSignInWithTOTP = "Confirm with TOTP"
    case confirmSignInWithOTP = "Confirm Sign In with OTP"

    var id: String { self.rawValue }

    func toAuthSignInStep() -> AuthSignInStep {
        switch self {
        case .done:
            return .done
        case .continueSignInWithMFASelection:
            return .continueSignInWithMFASelection(.init([.sms, .email, .totp]))
        case .continueSignInWithEmailMFASetup:
            return .continueSignInWithEmailMFASetup
        case .continueSignInWithMFASetupSelection:
            return .continueSignInWithMFASetupSelection(.init([.email, .totp]))
        case .confirmSignInWithEmailMFACode:
            return .confirmSignInWithOTP(.init(destination: .email("h***@a***.com")))
        case .confirmSignInWithPhoneMFACode:
            return .confirmSignInWithOTP(.init(destination: .phone("+11***")))
        case .confirmSignInWithTOTP:
            return .confirmSignInWithTOTPCode
        case .confirmSignInWithOTP:
            return .confirmSignInWithOTP(.init(destination: .email("tst@example.com")))
        }
    }
}

struct ContentView: View {
    @State private var selectedSignInStep: SignInNextStepForTesting = .done
    @State private var selectedConfirmSignInStep: ConfirmSignInNextStepForTesting = .done
    private let hidesSignUpButton: Bool
    private let initialStep: AuthenticatorInitialStep
    private let shouldUsePickerForTestingSteps: Bool
    private let signUpFields: [SignUpField]

    init(hidesSignUpButton: Bool,
         initialStep: AuthenticatorInitialStep,
         authSignInStep: AuthSignInStep,
         shouldUsePickerForTestingSteps: Bool = false,
         passwordlessFlow: Bool = false) {
        self.hidesSignUpButton = hidesSignUpButton
        self.initialStep = initialStep
        self.shouldUsePickerForTestingSteps = shouldUsePickerForTestingSteps
        
        if passwordlessFlow {
            self.signUpFields = []
        } else {
            self.signUpFields = Self.defaultSignUpFields
        }
        
        // Configure mocks for testing
        configureMocksForPasswordlessTesting()
        
        MockAuthenticationService.shared.mockedSignInResult = .init(nextStep: authSignInStep)
    }
    
    // MARK: - Mock Configuration Methods
    
    /// Configure mocks for passwordless authentication testing
    ///
    /// Multi-Step Authentication Flows:
    ///
    /// EMAIL/SMS OTP Flow:
    /// 1. Sign In → returns .continueSignInWithFirstFactorSelection(availableFactors)
    /// 2. Select Factor (SignInSelectAuthFactorView) → confirmSignIn("EMAIL_OTP") → returns .confirmSignInWithOTP
    /// 3. Enter OTP Code (ConfirmSignInWithOTPView) → confirmSignIn("123456") → returns .done
    ///
    /// Password Flow:
    /// 1. Sign In → returns .continueSignInWithFirstFactorSelection(availableFactors)
    /// 2. Select Factor (SignInSelectAuthFactorView) → confirmSignIn("PASSWORD") → returns .confirmSignInWithPassword
    /// 3. Enter Password (SignInConfirmPasswordView) → confirmSignIn("Pass@123") → returns .done
    ///
    /// The MockAuthenticationService.confirmSignIn() automatically handles these multi-step flows:
    /// - "EMAIL_OTP" or "SMS_OTP" → returns .confirmSignInWithOTP
    /// - "PASSWORD" or "PASSWORD_SRP" → returns .confirmSignInWithPassword
    /// - After OTP factor: 6-digit code → returns .done
    /// - After Password factor: password string → returns .done
    private func configureMocksForPasswordlessTesting() {
        let mockService = MockAuthenticationService.shared
        
        // Mock successful sign up with confirmation required
        mockService.mockedSignUpResult = AuthSignUpResult(
            .confirmUser(
                AuthCodeDeliveryDetails(destination: .email("test@example.com")),
                nil,
                "user-123"
            ),
            userID: "user-123"
        )
        
        // Mock successful confirm sign up with auto sign-in
        mockService.mockedConfirmSignUpResult = AuthSignUpResult(
            .completeAutoSignIn("mock-session-token"),
            userID: "user-123"
        )
        
        // Mock successful auto sign-in
        mockService.mockedAutoSignInResult = AuthSignInResult(nextStep: .done)
        
        // Configure user to be set when autoSignIn is called
        mockService.autoSignInUserToSet = MockAuthenticationService.User(
            username: "test@example.com",
            userId: "user-123"
        )
        
        mockService.mockedSignUpResult = AuthSignUpResult(
            .done
        )
    }

    var body: some View {
        if shouldUsePickerForTestingSteps {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 4) {
                    Text("Sign In Next Step")
                        .font(.headline)
                    Picker("", selection: $selectedSignInStep) {
                        ForEach(SignInNextStepForTesting.allCases) { step in
                            Text(step.rawValue).tag(step)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedSignInStep) { newStepForTesting in
                        // Update MockAuthenticationService when picker selection changes
                        MockAuthenticationService.shared.mockedSignInResult = .init(nextStep: newStepForTesting.toAuthSignInStep())
                    }
                }
                
                HStack(spacing: 4) {
                    Text("Confirm Sign In Next Step")
                        .font(.headline)
                    Picker("", selection: $selectedConfirmSignInStep) {
                        ForEach(ConfirmSignInNextStepForTesting.allCases) { step in
                            Text(step.rawValue).tag(step)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedConfirmSignInStep) { newStepForTesting in
                        // Update MockAuthenticationService when picker selection changes
                        MockAuthenticationService.shared.mockedConfirmSignInResult = .init(nextStep: newStepForTesting.toAuthSignInStep())
                    }
                }
            }
            .padding()
        }

        Authenticator(
            initialStep: initialStep,
            authenticationFlow: .userChoice(
                preferredAuthFactor: .password(),
                passkeyPrompts: .init(
                    afterSignUp: .always,
                    afterSignIn: .always))
        ) { state in
            VStack {
                Text("Hello, \(state.user.username)")
                Button("Sign out") {
                    Task { await state.signOut() }
                }
                .buttonStyle(.bordered)
            }
        }
        .hidesSignUpButton(hidesSignUpButton)
        .signUpFields(signUpFields)
        .authenticationService(MockAuthenticationService.shared)
        .onAppear {
            print("Appeared!")
        }
#if os(iOS)
        .statusBar(hidden: true)
#endif

    }

    private static var defaultSignUpFields: [SignUpField] {
        return [
            .password(isRequired: true),
            .confirmPassword(isRequired: true)
        ]
    }
}
