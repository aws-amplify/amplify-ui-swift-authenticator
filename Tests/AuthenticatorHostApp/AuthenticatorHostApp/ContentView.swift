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
    private var hidesSignUpButton = false

    init() {
        MockAuthenticationService.shared.mockedSignInResult = .init(nextStep: .confirmSignInWithTOTPCode)
    }

    var body: some View {
        Authenticator { state in
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
