//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import Authenticator

class MockAuthenticatorState: AuthenticatorStateProtocol {
    var authenticationService: AuthenticationService = MockAuthenticationService()

    var configuration = CognitoConfiguration(
        usernameAttributes: [],
        signupAttributes: [],
        passwordProtectionSettings: .init(minLength: 0, characterPolicy: []),
        verificationMechanisms: []
    )

    var setCurrentStepCount = 0
    var setCurrentStepValue: Step?
    func setCurrentStep(_ step: Step) {
        setCurrentStepCount += 1
        setCurrentStepValue = step
    }

    var mockedStep: Step?
    var step: Step {
        return mockedStep ?? .loading
    }

    var moveToCount = 0
    var moveToValue: AuthenticatorInitialStep?
    func move(to initialStep: AuthenticatorInitialStep) {
        moveToCount += 1
        moveToValue = initialStep
    }
}
