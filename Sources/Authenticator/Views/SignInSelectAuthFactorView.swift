//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents the content being displayed when the ``Authenticator`` is in the ``AuthenticatorStep/signInSelectAuthFactor`` step.
public struct SignInSelectAuthFactorView<Header: View,
                                         Footer: View>: View {
    @Environment(\.authenticatorState) private var authenticatorState
    @Environment(\.authenticatorTheme) var theme
    @StateObject private var passwordValidator: Validator
    @ObservedObject private var state: SignInSelectAuthFactorState
    private let headerContent: Header
    private let footerContent: Footer

    /// Creates a `SignInSelectAuthFactorView`
    /// - Parameter state: The ``SignInSelectAuthFactorState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``SignInSelectAuthFactorHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  ``SignInSelectAuthFactorFooter``
    public init(
        state: SignInSelectAuthFactorState,
        @ViewBuilder headerContent: () -> Header = {
            SignInSelectAuthFactorHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            SignInSelectAuthFactorFooter()
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

            // TODO: Implement auth factor selection UI
            // This should display available auth factors and allow selection
            
            // Show password field if password-based auth factor is selected
            if case .password = state.selectedAuthFactor {
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
            }

            Button("authenticator.signIn.button.signIn".localized()) {
                Task {
                    await selectAuthFactor()
                }
            }
            .buttonStyle(.primary)

            footerContent
        }
        .messageBanner($state.message)
        .onSubmit {
            Task {
                await selectAuthFactor()
            }
        }
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError?) -> Self {
        state.errorTransform = errorTransform
        return self
    }

    private func selectAuthFactor() async {
        guard let selectedFactor = state.selectedAuthFactor else {
            log.verbose("No auth factor selected")
            return
        }
        
        if case .password = selectedFactor {
            guard passwordValidator.validate() else {
                log.verbose("Password validation failed")
                return
            }
        }

        try? await state.selectAuthFactor()
    }
}

extension SignInSelectAuthFactorView: AuthenticatorLogging {}

/// Default header for the ``SignInSelectAuthFactorView``. It displays the view's title
public struct SignInSelectAuthFactorHeader: View {
    public init() {}
    public var body: some View {
        DefaultHeader(
            title: "authenticator.signInSelectAuthFactor.title".localized()
        )
    }
}

/// Default footer for the ``SignInSelectAuthFactorView``. It displays the "Back to Sign In" button
public struct SignInSelectAuthFactorFooter: View {
    @Environment(\.authenticatorState) private var authenticatorState

    public init() {}
    public var body: some View {
        Button("authenticator.signInSelectAuthFactor.button.backToSignIn".localized()) {
            authenticatorState.move(to: .signIn)
        }
        .buttonStyle(.link)
    }
}
