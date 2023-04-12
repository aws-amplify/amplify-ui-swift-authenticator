//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents the content being displayed when the Authenticator is in the `.confirmSignInWithNewPassword` step.
public struct ConfirmSignInWithNewPasswordView<Header: View,
                                               Footer: View>: View, KeyboardIterableFields {
    @Environment(\.authenticatorState) private var authenticatorState
    @StateObject private var passwordValidator: Validator
    @StateObject private var confirmPasswordValidator: Validator
    @ObservedObject private var state: ConfirmSignInWithNewPasswordState
    private let headerContent: Header
    private let footerContent: Footer

    var focusedField: FocusState<ConfirmSignInWithNewPasswordState.Field?> = FocusState()

    /// Creates a `ConfirmSignInWithNewPasswordView`
    /// - Parameter state: The ``ConfirmSignInWithNewPasswordState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``ConfirmSignInWithNewPasswordView``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  `EmptyView`
    public init(
        state: ConfirmSignInWithNewPasswordState,
        @ViewBuilder headerContent: () -> Header = {
            ConfirmSignInWithNewPasswordHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            EmptyView()
        }
    ) {
        self.state = state
        self.headerContent = headerContent()
        self.footerContent = footerContent()
        self._passwordValidator = StateObject(wrappedValue: Validator(
            using: { value in
                let configuration = state.configuration.passwordProtectionSettings
                return FieldValidators.password(
                    minLength: configuration.minLength,
                    characterPolicy: configuration.characterPolicy.asPasswordCharactersPolicy()
                )(value)
            }
        ))
        self._confirmPasswordValidator = StateObject(wrappedValue: Validator(
            using: { value in
                if value.isEmpty {
                    return FieldValidators.required(value)
                }
                if value != state.newPassword {
                    return "authenticator.validator.field.newPassword.doesNotMatch".localized()
                }

                return nil
            }
        ))
    }

    public var body: some View {
        AuthenticatorView(isBusy: state.isBusy) {
            headerContent

            PasswordField(
                "authenticator.field.newPassword.label".localized(),
                text: $state.newPassword,
                placeholder: "authenticator.field.newPassword.placeholder".localized(),
                validator: passwordValidator
            )
            .focused(focusedField.projectedValue, equals: .newPassword)
            .textContentType(.password)
            .textInputAutocapitalization(.never)

            PasswordField(
                "authenticator.field.confirmPassword.label".localized(),
                text: $state.confirmPassword,
                placeholder: "authenticator.field.confirmPassword.placeholder".localized(),
                validator: confirmPasswordValidator
            )
            .focused(focusedField.projectedValue, equals: .newPasswordConfirmation)
            .textContentType(.password)
            .textInputAutocapitalization(.never)

            Button("authenticator.confirmSignInWithNewPassword.button.submit".localized()) {
                Task {
                    await confirmSignIn()
                }
            }
            .buttonStyle(.primary)

            footerContent
        }
        .messageBanner($state.message)
        .keyboardIterableToolbar(fields: self)
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError) -> Self {
        state.errorTransform = errorTransform
        return self
    }

    private func confirmSignIn() async {
        let passwordValidation = passwordValidator.validate()
        let confirmPasswordValidation = confirmPasswordValidator.validate()

        guard passwordValidation, confirmPasswordValidation else {
            log.verbose("Password validations failed")
            return
        }

        try? await state.confirmSignIn()
    }
}

/// Default header for the ``ConfirmSignInWithNewPasswordView``. It displays the view's title
public struct ConfirmSignInWithNewPasswordHeader: View {
    public init() {}
    public var body: some View {
        DefaultHeader(
            title: "authenticator.confirmSignInWithNewPassword.title".localized()
        )
    }
}
