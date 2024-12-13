//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
@_spi(InternalAmplifyPluginExtension) import AWSCognitoAuthPlugin
@_spi(InternalAmplifyPluginExtension) import InternalAmplifyCredentials
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
            Self.log.error(error)
            Self.log.error("Unable to create AuthenticatorState")
            configuration = .empty
            step = .error(error)
            currentStep = .error
        }
    }

    /// Manually moves the Authenticator to an initial step
    /// - Parameter initialStep: The desired ``AuthenticatorInitialStep``
    public func move(to initialStep: AuthenticatorInitialStep) {
        if case .signedIn(_) = step {
            log.error("Cannot move to \(initialStep), the user is currently signed in. Call signOut first.")
            return
        }

        guard step != .init(from: initialStep) else {
            log.warn("Attempted to move to \(initialStep), but the Authenticator is already in that step.")
            return
        }

        setCurrentStep(.init(from: initialStep))
    }

    func setCurrentStep(_ step: Step) {
        if case .error(let error) = self.step {
            log.error(error)
            log.error("Cannot move to \(step), the Authenticator is in error state.")
            return
        }

        DispatchQueue.main.async {
            self.step = step
        }
    }

    func reloadState(initialStep: AuthenticatorInitialStep) async {
        if case .error(let error) = step {
            log.error(error)
            log.error("Cannot reload state, the Authenticator is in error state.")
            return
        }
        signedOutStep = .init(from: initialStep)

        do {
            let authSession = try await authenticationService.fetchAuthSession(options: nil)

            if authSession.isSignedIn {
                // The user has previously signed in, but validate if the session is still valid
                if isSessionValid(authSession) {
                    log.info("The user is signed in, going to signedIn step")
                    let user = try await authenticationService.getCurrentUser()
                    setCurrentStep(.signedIn(user: user))
                } else {
                    log.info("The user's credentials have expired. Signing out and going to signedOut step")
                    _ = await Amplify.Auth.signOut()
                    setCurrentStep(signedOutStep)
                }
            } else {
                log.info("The user is not signed in, going to signedOut step")
                setCurrentStep(signedOutStep)
            }

        } catch {
            log.error(error)
            log.error("Error while attempting to determine signed in user, going signedOut step")
            setCurrentStep(signedOutStep)
        }
    }

    private func isSessionValid(_ session: AuthSession) -> Bool {
        guard let cognitoSession = session as? AWSAuthCognitoSession else {
            // Consider non-Cognito sessions to be valid if it's signed in
            return session.isSignedIn
        }

        // If the failures are caused due to connectivity errors, consider the session still valid
        if configuration.hasIdentityPool,
           case .failure(let authError) = cognitoSession.getIdentityId(),
           !authError.isConnectivityError {
            log.verbose("Could not fetch Identity ID")
            return false
        }

        if configuration.hasUserPool,
           case .failure(let authError) = cognitoSession.getCognitoTokens(),
           !authError.isConnectivityError {
            log.verbose("Could not fetch Cognito Tokens")
            return false
        }

        return true
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
