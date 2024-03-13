//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI
@_spi(InternalAmplifyConfiguration) import AWSCognitoAuthPlugin

/// Represents the content being displayed when the ``Authenticator`` is in the ``AuthenticatorStep/confirmResetPassword`` step.
public struct ConfirmResetPasswordView<Header: View,
                                       Footer: View>: View, KeyboardIterableFields {
    @Environment(\.authenticatorState) private var authenticatorState
    @StateObject private var codeValidator: Validator
    @StateObject private var passwordValidator: Validator
    @StateObject private var confirmPasswordValidator: Validator
    @ObservedObject private var state: ConfirmResetPasswordState
    private let headerContent: Header
    private let footerContent: Footer

    var focusedField: FocusState<ConfirmResetPasswordState.Field?> = FocusState()

    /// Creates a `ConfirmResetPasswordView`
    /// - Parameter state: The ``ConfirmResetPasswordState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``ConfirmResetPasswordHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  ``ConfirmResetPasswordFooter``
    public init(
        state: ConfirmResetPasswordState,
        @ViewBuilder headerContent: () -> Header = {
            ConfirmResetPasswordHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            ConfirmResetPasswordFooter()
        }
    ) {
        self.state = state
        self.headerContent = headerContent()
        self.footerContent = footerContent()
        self._codeValidator = StateObject(wrappedValue: Validator(
            using: FieldValidators.required
        ))
        self._passwordValidator = StateObject(wrappedValue: Validator(
            using: { value in
                let configuration = state.configuration.passwordProtectionSettings
                return FieldValidators.password(
                    minLength: configuration.minLength ?? 0,
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

            TextField(
                "authenticator.field.code.label".localized(),
                text: $state.confirmationCode,
                placeholder: "authenticator.field.code.placeholder".localized(),
                validator: codeValidator
            )
            .focused(focusedField.projectedValue, equals: .confirmationCode)
            .textContentType(.oneTimeCode)
        #if os(iOS)
            .keyboardType(.default)
        #endif

            PasswordField(
                "authenticator.field.newPassword.label".localized(),
                text: $state.newPassword,
                placeholder: "authenticator.field.newPassword.placeholder".localized(),
                validator: passwordValidator
            )
            .focused(focusedField.projectedValue, equals: .newPassword)
        #if os(iOS)
            .textContentType(.newPassword)
            .textInputAutocapitalization(.never)
        #elseif os(macOS)
            .textContentType(.password)
        #endif

            PasswordField(
                "authenticator.field.confirmPassword.label".localized(),
                text: $state.confirmPassword,
                placeholder: "authenticator.field.confirmPassword.placeholder".localized(),
                validator: confirmPasswordValidator
            )
            .focused(focusedField.projectedValue, equals: .newPasswordConfirmation)
        #if os(iOS)
            .textContentType(.newPassword)
            .textInputAutocapitalization(.never)
        #elseif os(macOS)
            .textContentType(.password)
        #endif

            Button("authenticator.confirmResetPassword.button.submit".localized()) {
                Task {
                    await confirmResetPassword()
                }
            }
            .buttonStyle(.primary)

            footerContent
        }
        .messageBanner($state.message)
        .keyboardIterableToolbar(fields: self)
        .onAppear {
            state.message = .info(
                message: state.localizedMessage(for: state.deliveryDetails)
            )
        }
        .onSubmit {
            if hasNextField {
                focusNextField()
            } else {
                Task {
                    await confirmResetPassword()
                }
            }
        }
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError) -> Self {
        state.errorTransform = errorTransform
        return self
    }

    private func confirmResetPassword() async {
        let codeValidation = codeValidator.validate()
        let passwordValidation = passwordValidator.validate()
        let confirmPasswordValidation = confirmPasswordValidator.validate()

        guard codeValidation, passwordValidation, confirmPasswordValidation else {
            log.verbose("Some input validations failed")
            return
        }

        try? await state.confirmResetPassword()
    }
}

/// Default header for the ``ConfirmResetPasswordView``. It displays the view's title
public struct ConfirmResetPasswordHeader: View {
    public init() {}
    public var body: some View {
        DefaultHeader(
            title: "authenticator.confirmResetPassword.title".localized()
        )
    }
}

/// Default footer for the ``ConfirmResetPasswordView``. It displays the "Back to Sign In" button
public struct ConfirmResetPasswordFooter: View {
    @Environment(\.authenticatorState) private var authenticatorState

    public init() {}
    public var body: some View {
        Button("authenticator.confirmResetPassword.button.backToSignIn".localized()) {
            authenticatorState.move(to: .signIn)
        }
        .buttonStyle(.link)
    }
}
