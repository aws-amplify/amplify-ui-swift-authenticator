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
            return .confirmSignInWithEmailMFACode(.init(destination: .email("h***@a***.com")))
        case .confirmSignInWithPhoneMFACode:
            return .confirmSignInWithEmailMFACode(.init(destination: .phone("+11***")))
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
        MockAuthenticationService.shared.mockedSignInResult = .init(nextStep: authSignInStep)
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

        Authenticator(initialStep: initialStep) { state in
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
        return []
    }
}
