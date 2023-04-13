//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents the content being displayed when the Authenticator is in the `.resetPassword` step.
///
/// This view will automatically determine what type of login mechanism (i.e. username, email, phone number) is configured
/// and display the appropiate field.
public struct ResetPasswordView<Header: View,
                                Footer: View>: View {
    @Environment(\.authenticatorState) private var authenticatorState
    @StateObject private var usernameValidator: Validator
    @ObservedObject private var state: ResetPasswordState
    private let headerContent: Header
    private let footerContent: Footer

    /// Creates a `ResetPasswordView`
    /// - Parameter state: The ``ResetPasswordState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``ResetPasswordHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  ``ResetPasswordFooter``
    public init(
        state: ResetPasswordState,
        @ViewBuilder headerContent: () -> Header = {
            ResetPasswordHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            ResetPasswordFooter()
        }
    ) {
        self.state = state
        self.headerContent = headerContent()
        self.footerContent = footerContent()
        self._usernameValidator = StateObject(wrappedValue: Validator(
            using: { value in
                if state.configuration.usernameAttribute == .email {
                    return FieldValidators.email(value)
                } else {
                    return FieldValidators.required(value)
                }
            }
        ))
    }

    public var body: some View {
        AuthenticatorView(isBusy: state.isBusy) {
            headerContent
            
            createUsernameInput(for: authenticatorState.configuration.usernameAttribute)
                .textInputAutocapitalization(.never)
                .textContentType(.username)
                      
            Button("authenticator.resetPassword.button.sendCode".localized()) {
                Task {
                    await resetPassword()
                }
            }
            .buttonStyle(.primary)
            
            footerContent
        }
        .messageBanner($state.message)
    }

    @ViewBuilder private func createUsernameInput(
        for usernameAttribute: CognitoConfiguration.UsernameAttribute
    ) -> some View {
        switch usernameAttribute {
        case .username:
            TextField(
                "authenticator.field.username.label".localized(),
                text: $state.username,
                placeholder: "authenticator.field.username.placeholder".localized(),
                validator: usernameValidator
            )
            .keyboardType(.default)
        case .email:
            TextField(
                "authenticator.field.email.label".localized(),
                text: $state.username,
                placeholder: "authenticator.field.email.placeholder".localized(),
                validator: usernameValidator
            )
            .keyboardType(.emailAddress)
        case .phoneNumber:
            TextField(
                "authenticator.field.phoneNumber.label".localized(),
                text: $state.username,
                placeholder: "authenticator.field.phoneNumber.placeholder".localized(),
                validator: usernameValidator
            )
            .keyboardType(.phonePad)
        }
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError) -> Self {
        state.errorTransform = errorTransform
        return self
    }

    private func resetPassword() async {
        guard usernameValidator.validate() else {
            log.verbose("Username validation failed")
            return
        }

        try? await state.resetPassword()
    }
}

extension ResetPasswordView: AuthenticatorLogging {}

/// Default header for the ``ResetPasswordView``. It displays the view's title
public struct ResetPasswordHeader: View {
    public init() {}
    public var body: some View {
        DefaultHeader(
            title: "authenticator.resetPassword.title".localized()
        )
    }
}

/// Default footer for the ``ResetPasswordView``. It displays the "Back to Sign In" button
public struct ResetPasswordFooter: View {
    @Environment(\.authenticatorState) private var authenticatorState

    public init() {}
    public var body: some View {
        Button("authenticator.resetPassword.button.backToSignIn".localized()) {
            authenticatorState.move(to: .signIn)
        }
        .buttonStyle(.link)
    }
}
