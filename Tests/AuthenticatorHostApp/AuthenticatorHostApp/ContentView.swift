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
    private var hidesSignUpButton = true
    private var initialStep = AuthenticatorInitialStep.signIn

    init() {
        MockAuthenticationService.shared.mockedSignInResult = .init(nextStep: .confirmSignInWithTOTPCode)
        processUITestLaunchArguments()

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

    mutating func processUITestLaunchArguments() {
        let uiTestArguments = ProcessInfo.processInfo.arguments
        var arguments: [ProcessArgument] = []
        for (index, argument) in uiTestArguments.enumerated() {
            if argument.isEqual("-uiTestArgsData") {
                arguments = try! JSONDecoder().decode([ProcessArgument].self, from: uiTestArguments[index + 1].data(using: .utf8)!)
                break
            }
        }

        for argument in arguments {
            switch argument {
            case .initialStep(let step):
                self.initialStep = step
            case .hidesSignUpButton(let hidesSignUpButton):
                self.hidesSignUpButton = hidesSignUpButton
            }
        }
    }

    private var signUpFields: [SignUpField] {
        return []
    }
}
