//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@testable import Authenticator
import AWSCognitoAuthPlugin
import SwiftUI

@main
struct AuthenticatorHostApp: App {

    private let factory = AuthCategoryConfigurationFactory.shared
    private var hidesSignUpButton = false
    private var initialStep = AuthenticatorInitialStep.signIn
    private var authSignInNextStep = AuthSignInStep.done
    private var shouldUsePickerForTestingSteps = false

    var body: some Scene {
        WindowGroup {
            ContentView(
                hidesSignUpButton: hidesSignUpButton,
                initialStep: initialStep,
                authSignInStep: authSignInNextStep,
                shouldUsePickerForTestingSteps: shouldUsePickerForTestingSteps)
        }
    }

    init() {
        processUITestLaunchArguments()
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure(AmplifyConfiguration(auth: factory.createConfiguration()))
        } catch {
            print("Unable to configure Amplify \(error)")
        }
    }

    mutating func modifyConfiguration(for argument: ProcessArgument) {
        switch argument {
        case .initialStep(let step):
            self.initialStep = step
        case .hidesSignUpButton(let hidesSignUpButton):
            self.hidesSignUpButton = hidesSignUpButton
        case .userAttributes(let userAttributes):
            factory.setUserAtributes(userAttributes)
        case .authSignInStep(let authUITestNextStep):
            self.authSignInNextStep = getMockedNextStepResult(from: authUITestNextStep)
        }
    }

    mutating func processUITestLaunchArguments() {
        let uiTestArguments = ProcessInfo.processInfo.arguments
        var arguments: [ProcessArgument] = []
        for (index, argument) in uiTestArguments.enumerated() {
            if argument.isEqual(UITestKeyKey) {
                // If no UI tests arguments is present,
                // that means we can show the picker for testing.
                shouldUsePickerForTestingSteps = false
                arguments = try! JSONDecoder().decode([ProcessArgument].self, from: uiTestArguments[index + 1].data(using: .utf8)!)
                break
            }
        }
        for argument in arguments {
            modifyConfiguration(for: argument)
        }
    }

    private func getMockedNextStepResult(from authUITestSignInStep: AuthUITestSignInStep) -> AuthSignInStep {
        switch authUITestSignInStep {
        case .confirmSignInWithSMSMFACode:
            return .confirmSignInWithSMSMFACode(.init(destination: .email("111-222-3333")), nil)
        case .confirmSignInWithCustomChallenge:
            return .confirmSignInWithCustomChallenge(nil)
        case .confirmSignInWithNewPassword:
            return .confirmSignInWithNewPassword(nil)
        case .confirmSignInWithTOTPCode:
            return .confirmSignInWithTOTPCode
        case .continueSignInWithTOTPSetup:
            return .continueSignInWithTOTPSetup(.init(sharedSecret: "secret", username: "username"))
        case .continueSignInWithMFASelection:
            return .continueSignInWithMFASelection([.totp, .sms, .email])
        case .continueSignInWithMFASetupSelection:
            return .continueSignInWithMFASetupSelection([.totp, .email])
        case .continueSignInWithEmailMFASetup:
            return .continueSignInWithEmailMFASetup
        case .confirmSignInWithEmailMFACode:
            return .confirmSignInWithOTP(.init(destination: .email("test@amazon.com")))
        case .resetPassword:
            return .resetPassword(nil)
        case .confirmSignUp:
            return .confirmSignUp(nil)
        case .done:
            return .done
        }
    }
}
