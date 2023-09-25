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

struct ContentView: View {
    private let hidesSignUpButton: Bool
    private let initialStep: AuthenticatorInitialStep

    init(hidesSignUpButton: Bool,
         initialStep: AuthenticatorInitialStep,
         authSignInStep: AuthSignInStep) {
        self.hidesSignUpButton = hidesSignUpButton
        self.initialStep = initialStep
        MockAuthenticationService.shared.mockedSignInResult = .init(nextStep: authSignInStep)
    }

    var body: some View {
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
        .statusBar(hidden: true)
    }



    private var signUpFields: [SignUpField] {
        return []
    }
}
