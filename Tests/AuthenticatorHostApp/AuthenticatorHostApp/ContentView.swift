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
            return .continueSignInWithFirstFactorSelection([.emailOTP, .smsOTP, .password, .passwordSRP, .webAuthn])
        case .confirmSignInWithOTP:
            return .confirmSignInWithOTP(.init(destination: .email("tst@example.com")))
        case .confirmSignInWithPassword:
            return .confirmSignInWithPassword
        }
    }
}

struct ContentView: View {
    @State private var selectedStep: SignInNextStepForTesting = .done
    private let hidesSignUpButton: Bool
    private let initialStep: AuthenticatorInitialStep
    private let shouldUsePickerForTestingSteps: Bool

    init(hidesSignUpButton: Bool,
         initialStep: AuthenticatorInitialStep,
         authSignInStep: AuthSignInStep,
         shouldUsePickerForTestingSteps: Bool = false) {
        self.hidesSignUpButton = hidesSignUpButton
        self.initialStep = initialStep
        self.shouldUsePickerForTestingSteps = shouldUsePickerForTestingSteps
        
        // Configure mocks for testing
        configureMocksForPasswordlessTesting()
        
        MockAuthenticationService.shared.mockedSignInResult = .init(nextStep: authSignInStep)
    }
    
    // MARK: - Mock Configuration Methods
    
    /// Configure mocks for passwordless authentication testing
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
    }

    var body: some View {
        if shouldUsePickerForTestingSteps {
            Picker("Next Step", selection: $selectedStep) {
                ForEach(SignInNextStepForTesting.allCases) { step in
                    Text(step.rawValue).tag(step)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .onChange(of: selectedStep) { newStepForTesting in
                // Update MockAuthenticationService when picker selection changes
                MockAuthenticationService.shared.mockedSignInResult = .init(nextStep: newStepForTesting.toAuthSignInStep())
            }
        }

        Authenticator(
            initialStep: initialStep,
            authenticationFlow: .userChoice() // Testing UserChoice with no preferred auth factor
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

    private var signUpFields: [SignUpField] {
        return [
            .email(isRequired: true),
        ]
    }
}
