//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

/// The state observed by the Continue Sign In with TOTP Setup content views, representing the ``Authenticator`` is  the ``AuthenticatorStep/continueSignInWithTOTPSetup`` step.
public class ContinueSignInWithTOTPSetupState: AuthenticatorBaseState {
    /// The confirmation code provided by the user
    @Published public var confirmationCode: String = ""

    private let issuer: String?

    init(credentials: Credentials, issuer: String?) {
        self.issuer = issuer
        super.init(credentials: credentials)
    }

    /// The `Amplify.TOTPSetupDetails.sharedSecret` associated with this state. If the Authenticator is not in the `.continueSignInWithTOTPSetup` step, it returns `nil` result
    public var sharedSecret: String? {
        guard case .continueSignInWithTOTPSetup(let totpSetupDetails) = authenticatorState.step else {
            return nil
        }

        return totpSetupDetails.sharedSecret
    }

    /// The `Amplify.TOTPSetupDetails.getSetupURI` associated with this state. If the Authenticator is not in the `.continueSignInWithTOTPSetup` step, it returns `nil` result
    public var setupUri: String? {
        guard case .continueSignInWithTOTPSetup(let totpSetupDetails) = authenticatorState.step else {
            return nil
        }

        guard let issuer = extractIssuerForQRCodeGeneration() else {
            return nil
        }

        let qrCodeURIString: String
        do {
            qrCodeURIString = try totpSetupDetails.getSetupURI(appName: issuer).absoluteString
        } catch {
            log.error(error: error)
            return nil
        }

        return qrCodeURIString
    }

    private func extractIssuerForQRCodeGeneration() -> String? {
        if let issuer = issuer {
            return issuer
        }
        log.warn("`totpOptions` not provided as part of initialization. Falling back to extract application name from Bundle.")

        if let applicationName = Bundle.main.applicationName {
            return applicationName
        }
        log.error("Unable to extract the application name from Bundle")
        return nil
    }

    /// Attempts to continue the user's sign in using the provided confirmation code.
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func continueSignIn() async throws {
        setBusy(true)

        do {
            log.verbose("Attempting to confirm Sign Up")
            let result = try await authenticationService.confirmSignIn(
                challengeResponse: confirmationCode,
                options: nil
            )
            let nextStep = try await nextStep(for: result)

            setBusy(false)

            authenticatorState.setCurrentStep(nextStep)
        } catch {
            log.error("Confirm Sign In with Code failed")
            let authenticationError = self.error(for: error)
            setMessage(authenticationError)
            throw authenticationError
        }
    }
}
