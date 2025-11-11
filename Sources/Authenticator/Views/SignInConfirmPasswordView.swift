//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents the content being displayed when the ``Authenticator`` is in the ``AuthenticatorStep/signInConfirmPassword`` step.
public struct SignInConfirmPasswordView<Header: View,
                                        Footer: View>: View {
    @Environment(\.authenticatorState) private var authenticatorState
    @Environment(\.authenticatorTheme) var theme
    @StateObject private var passwordValidator: Validator
    @ObservedObject private var state: SignInConfirmPasswordState
    private let headerContent: Header
    private let footerContent: Footer

    /// Creates a `SignInConfirmPasswordView`
    /// - Parameter state: The ``SignInConfirmPasswordState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``SignInConfirmPasswordHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  ``SignInConfirmPasswordFooter``
    public init(
        state: SignInConfirmPasswordState,
        @ViewBuilder headerContent: () -> Header = {
            SignInConfirmPasswordHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            SignInConfirmPasswordFooter()
        }
    ) {
        self._state = ObservedObject(wrappedValue: state)
        self.headerContent = headerContent()
        self.footerContent = footerContent()
        self._passwordValidator = StateObject(wrappedValue: Validator(
            using: FieldValidators.required
        ))
    }

    public var body: some View {
        AuthenticatorView(isBusy: state.isBusy) {
            headerContent
            
            TextField(
                "authenticator.field.username.label".localized(),
                text: .constant(state.username),
                placeholder: ""
            )
            .disabled(true)

            PasswordField(
                "authenticator.field.password.label".localized(),
                text: $state.password,
                placeholder: "authenticator.field.password.placeholder".localized(),
                validator: passwordValidator
            )
            .textContentType(.password)
        #if os(iOS)
            .textInputAutocapitalization(.never)
        #endif

            Button("authenticator.signInConfirmPassword.button.confirm".localized()) {
                Task {
                    await confirmPassword()
                }
            }
            .buttonStyle(.primary)

            footerContent
        }
        .messageBanner($state.message)
        .onSubmit {
            Task {
                await confirmPassword()
            }
        }
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError?) -> Self {
        state.errorTransform = errorTransform
        return self
    }

    private func confirmPassword() async {
        guard passwordValidator.validate() else {
            log.verbose("Password validation failed")
            return
        }

        try? await state.confirmPassword()
    }
}

extension SignInConfirmPasswordView: AuthenticatorLogging {}

/// Default header for the ``SignInConfirmPasswordView``. It displays the view's title
public struct SignInConfirmPasswordHeader: View {
    public init() {}
    public var body: some View {
        DefaultHeader(
            title: "authenticator.signInConfirmPassword.title".localized()
        )
    }
}

/// Default footer for the ``SignInConfirmPasswordView``. It displays the "Back to Sign In" button
public struct SignInConfirmPasswordFooter: View {
    @Environment(\.authenticatorState) private var authenticatorState

    public init() {}
    public var body: some View {
        Button("authenticator.signInConfirmPassword.button.backToSignIn".localized()) {
            authenticatorState.move(to: .signIn)
        }
        .buttonStyle(.link)
    }
}
