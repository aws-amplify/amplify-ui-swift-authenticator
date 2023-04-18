//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@_spi(InternalAmplifyPluginExtension) import AWSCognitoAuthPlugin
@_spi(InternalAmplifyPluginExtension) import AWSPluginsCore
import Foundation

/// An `ObservableObject` that represents the Authenticator's state
/// It can be retrieved  through `@Environment(\.authenticatorState)`
public class AuthenticatorState: ObservableObject, AuthenticatorStateProtocol {
    /// The Authenticator's current ``AuthenticatorStep``, representing the current content being displayed.
    @Published private(set) public var currentStep: AuthenticatorStep
    
    @Published private(set) var step: Step {
        didSet {
            currentStep = step.authenticatorStep
        }
    }

    let configuration: CognitoConfiguration
    private(set) var signedOutStep: Step = .signIn
    var authenticationService: AuthenticationService = .default
    private var signOutToken: UnsubscribeToken?

    init() {
        do {
            configuration = try AmplifyConfiguration().cognito
            step = .loading
            currentStep = .loading
            setUserAgentSuffix()
            signOutToken = Amplify.Hub.listen(to: .auth, eventName: HubPayload.EventName.Auth.signedOut) { [weak self] payload in
                if payload.eventName == HubPayload.EventName.Auth.signedOut {
                    guard let self = self else { return }
                    self.setCurrentStep(self.signedOutStep)
                }
            }
        } catch {
            Self.log.error(error: error)
            Self.log.error("Unable to create AuthenticatorState")
            configuration = .empty
            step = .error(error)
            currentStep = .error
        }
    }

    func move(to initialStep: AuthenticatorInitialStep) {
        if case .signedIn(_) = step {
            log.error("Cannot move to \(initialStep), the user is currently signed in. Call signOut first.")
            return
        }

        setCurrentStep(.init(from: initialStep))
    }

    func setCurrentStep(_ step: Step) {
        if case .error(_) = step {
            log.error("Cannot move to \(step), the Authenticator is in error state.")
            return
        }

        DispatchQueue.main.async {
            self.step = step
        }
    }

    func reloadState(initialStep: AuthenticatorInitialStep) async {
        if case .error(let error) = step {
            log.error("Cannot reload state, the Authenticator is in error state.")
            log.error(error: error)
            return
        }
        signedOutStep = .init(from: initialStep)

        do {
            let authSession = try await authenticationService.fetchAuthSession(options: nil)

            if authSession.isSignedIn {
                let user = try await authenticationService.getCurrentUser()
                log.info("The user is signed in, going to signedIn step")
                setCurrentStep(.signedIn(user: user))
            } else {
                log.info("The user is not signed in, going to signedOut step")
                setCurrentStep(signedOutStep)
            }

        } catch {
            log.error(error: error)
            log.error("Error while attempting to determine signed in user, going signedOut step")
            setCurrentStep(signedOutStep)
        }
    }

    private func setUserAgentSuffix() {
        guard let plugin = try? Amplify.Auth.getPlugin(for: "awsCognitoAuthPlugin") as? AWSCognitoAuthPlugin else {
            log.error("Unable to retrieve the AWSCognitoAuthPlugin")
            return
        }

        let suffix = "lib/\(ComponentInformation.name)/\(ComponentInformation.version)"
        plugin.add(pluginExtension: UserAgentSuffixAppender(suffix: suffix))
    }
}

extension AuthenticatorState: AuthenticatorLogging {}
