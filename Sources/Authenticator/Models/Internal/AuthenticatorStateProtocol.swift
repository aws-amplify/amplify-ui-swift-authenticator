//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation

protocol AuthenticatorStateProtocol {
    var authenticationService: AuthenticationService { get }
    var configuration: CognitoConfiguration { get }
    var step: Step { get }
    func setCurrentStep(_ step: Step)
    func move(to initialStep: AuthenticatorInitialStep)
}

extension AuthenticatorStateProtocol where Self == EmptyAuthenticatorState {
    static var empty: AuthenticatorStateProtocol {
        return EmptyAuthenticatorState()
    }
}

struct EmptyAuthenticatorState: AuthenticatorStateProtocol {
    var authenticationService: AuthenticationService = .default
    var configuration: CognitoConfiguration = .empty
    var step: Step = .loading
    func setCurrentStep(_ step: Step) {}
    func move(to initialStep: AuthenticatorInitialStep) {}
}
