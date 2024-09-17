//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation

/// A utility class meant to provide 
public enum PreviewFactory {
    public enum States {
        /// Returns an empty and no-op ``SignInState``.
        public static func signIn() -> SignInState {
            return .init(credentials: .init())
        }

        /// Returns an empty and no-op ``ConfirmSignInWithCodeState``.
        /// - Parameter deliveryDetails: The ``AuthCodeDeliveryDetails`` associated with this state
        public static func confirmSignInWithCode(deliveryDetails: AuthCodeDeliveryDetails? = nil) -> ConfirmSignInWithCodeState {
            return ConfirmSignInWithCodeState(
                authenticatorState: .empty(with: .confirmSignInWithMFACode(deliveryDetails: deliveryDetails))
            )
        }

        /// Returns an empty and no-op ``ConfirmSignInWithNewPasswordState``.
        public static func confirmSignInWithNewPassword() -> ConfirmSignInWithNewPasswordState {
            return .init(credentials: .init())
        }

        /// Returns an empty and no-op ``ContinueSignInWithMFASelectionState``.
        /// - Parameter allowedMFATypes: The ``AllowedMFATypes`` associated with this state
        public static func continueSignInWithMFASelection(allowedMFATypes: AllowedMFATypes) -> ContinueSignInWithMFASelectionState {
            return .init(
                authenticatorState: .empty,
                allowedMFATypes: allowedMFATypes
            )
        }

        /// Returns an empty and no-op ``ContinueSignInWithTOTPSetupState``.
        /// - Parameter issuer: The issuer associated with this state
        /// - Parameter totpSetupDetails: The ``TOTPSetupDetails`` associated with this state
        public static func continueSignInWithTOTPSetup(
            issuer: String? = nil,
            totpSetupDetails: TOTPSetupDetails
        ) -> ContinueSignInWithTOTPSetupState {
            return .init(
                authenticatorState: .empty,
                issuer: issuer,
                totpSetupDetails: totpSetupDetails
            )
        }

        /// Returns an empty and no-op ``SignUpState``.
        /// - Parameter signUpFields: The list of ``SignUpField``s associated with this state
        public static func signUp(signUpFields: [SignUpField] = []) -> SignUpState {
            let state = SignUpState(credentials: .init())
            state.configure(with: signUpFields)
            return state
        }

        /// Returns an empty and no-op ``ConfirmSignUpState``.
        /// - Parameter deliveryDetails: The ``AuthCodeDeliveryDetails`` associated with this state
        public static func confirmSignUp(deliveryDetails: AuthCodeDeliveryDetails? = nil) -> ConfirmSignUpState {
            return .init(
                authenticatorState: .empty(with: .confirmSignUp(deliveryDetails: deliveryDetails)),
                credentials: .init()
            )
        }

        /// Returns an empty and no-op ``ResetPasswordState``.
        public static func resetPasword() -> ResetPasswordState {
            return .init(credentials: .init())
        }

        /// Returns an empty and no-op ``ConfirmResetPasswordState``.
        /// - Parameter deliveryDetails: The ``AuthCodeDeliveryDetails`` associated with this state
        public static func confirmResetPassword(deliveryDetails: AuthCodeDeliveryDetails? = nil) -> ConfirmResetPasswordState {
            return .init(
                authenticatorState: .empty(with: .confirmResetPassword(deliveryDetails: deliveryDetails)),
                credentials: .init()
            )
        }

        /// Returns an empty and no-op ``VerifyUserState``.
        /// - Parameter unverifiedFields: The list of ``AuthUserAttributeKey``s associated with this state
        public static func verifyUser(unverifiedFields: [AuthUserAttributeKey] = []) -> VerifyUserState {
            return .init(
                authenticatorState: .empty(with: .verifyUser(attributes: unverifiedFields)),
                credentials: .init()
            )
        }

        /// Returns an empty and no-op ``ConfirmVerifyUserState``.
        /// - Parameter userAttributeKey: The ``AuthUserAttributeKey`` associated with this state
        /// - Parameter deliveryDetails: The ``AuthCodeDeliveryDetails`` associated with this state
        public static func confirmVerifyUser(
            userAttributeKey: AuthUserAttributeKey,
            deliveryDetails: AuthCodeDeliveryDetails? = nil
        ) -> ConfirmVerifyUserState {
            return .init(
                authenticatorState: .empty(
                    with: .confirmVerifyUser(
                        attribute: userAttributeKey,
                        deliveryDetails: deliveryDetails
                    )
                ),
                credentials: .init()
            )
        }

        /// Returns an empty and no-op ``ContinueSignInWithEmailMFASetupState``.
        public static func continueSignInWithEmailMFASetup() -> ContinueSignInWithEmailMFASetupState {
            return .init(credentials: .init())
        }

        /// Returns an empty and no-op ``ContinueSignInWithMFASetupSelectionState``.
        /// - Parameter allowedMFATypes: The ``AllowedMFATypes`` associated with this state
        public static func continueSignInWithMFASetupSelection(
            allowedMFATypes: AllowedMFATypes
        ) -> ContinueSignInWithMFASetupSelectionState {
            return .init(
                authenticatorState: .empty,
                allowedMFATypes: allowedMFATypes
            )
        }

    }
}

private extension AuthenticatorStateProtocol where Self == EmptyAuthenticatorState {
    static func empty(with step: Step) -> AuthenticatorStateProtocol {
        return EmptyAuthenticatorState(step: step)
    }
}

