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
    private let totpSetupDetails: TOTPSetupDetails

    init(authenticatorState: AuthenticatorStateProtocol,
         issuer: String?,
         totpSetupDetails: TOTPSetupDetails) {
        self.totpSetupDetails = totpSetupDetails
        self.issuer = issuer
        super.init(authenticatorState: authenticatorState,
                   credentials: Credentials())
    }

    /// The `Amplify.TOTPSetupDetails.sharedSecret` associated with this state.
    public var sharedSecret: String {
        return totpSetupDetails.sharedSecret
    }

    /// The `Amplify.TOTPSetupDetails.getSetupURI` associated with this state.
    public var setupURI: String {
        var setupURIAccountName: String = ""
        if let issuer = extractIssuerForQRCodeGeneration() {
            setupURIAccountName = issuer + ":" + totpSetupDetails.username
            return "otpauth://totp/\(setupURIAccountName)?secret=\(sharedSecret)" + "&issuer=\(issuer)"
        } else {
            return "otpauth://totp/\(setupURIAccountName)?secret=\(sharedSecret)"

        }
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
            log.verbose("Attempting to confirm Sign In with Code")
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
