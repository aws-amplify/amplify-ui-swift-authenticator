//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents the content being displayed when the ``Authenticator`` is in the ``AuthenticatorStep/signIn`` step.
///
/// This view will automatically determine what type of login mechanism (i.e. username, email, phone number) is configured
/// and display the appropiate field.
public struct SignInView<Header: View,
                         Footer: View>: View, KeyboardIterableFields {
    @Environment(\.authenticatorState) private var authenticatorState
    @Environment(\.authenticatorOptions) private var options
    @StateObject private var usernameValidator: Validator
    @StateObject private var passwordValidator: Validator
    @ObservedObject private var state: SignInState
    private let headerContent: Header
    private let footerContent: Footer
    private var viewModifiers = ViewModifiers()

    var focusedField: FocusState<SignInState.Field?> = FocusState()

    /// Creates a `SignInView`
    /// - Parameter state: The ``SignInState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``SignInHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  ``SignInFooter``
    public init(
        state: SignInState,
        @ViewBuilder headerContent: () -> Header = {
            SignInHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            SignInFooter()
        }
    ) {
        self.state = state
        self.focusedField.wrappedValue = nil
        self.headerContent = headerContent()
        self.footerContent = footerContent()
        self._usernameValidator = StateObject(wrappedValue: Validator(
            using: { value in
                switch state.configuration.usernameAttribute {
                case .username:
                    return FieldValidators.required(value)
                case .email:
                    return FieldValidators.combined(
                        FieldValidators.required,
                        FieldValidators.email
                    )(value)
                case .phoneNumber:
                    return FieldValidators.combined(
                        FieldValidators.required,
                        FieldValidators.phoneNumber
                    )(value)
                }
            }
        ))
        self._passwordValidator = StateObject(wrappedValue: Validator(
            using: FieldValidators.required
        ))
    }

    public var body: some View {
        AuthenticatorView(isBusy: state.isBusy) {
            headerContent

            createUsernameInput(for: authenticatorState.configuration.usernameAttribute)
                .focused(focusedField.projectedValue, equals: .username)
                .textContentType(.username)
            #if os(iOS)
                .textInputAutocapitalization(.never)
            #endif

            PasswordField(
                "authenticator.field.password.label".localized(),
                text: $state.password,
                placeholder: "authenticator.field.password.placeholder".localized(),
                validator: passwordValidator
            )
            .focused(focusedField.projectedValue, equals: .password)
            .textContentType(.password)
        #if os(iOS)
            .textInputAutocapitalization(.never)
        #endif

            Button("authenticator.signIn.button.signIn".localized()) {
                Task {
                    await signIn()
                }
            }
            .buttonStyle(.primary)

            footerContent
                .environment(\.authenticatorOptions.hidesSignUpButton, shouldHideSignUpButton)
        }
        .messageBanner($state.message)
        .keyboardIterableToolbar(fields: self)
        .onSubmit {
            if hasNextField {
                focusNextField()
            } else {
                Task {
                    await signIn()
                }
            }
        }
        .onAppear {
            state.password = ""
            if let message = state.credentials.message {
                state.message = message
            }
        }
    }

    /// Hides the Sign Up Button that is displayed in the default ``SignInView``.
    /// - Parameter hidesSignUpButton: Whether to hide the Sign Up button. Defaults to true.
    public func hidesSignUpButton(_ hidesSignUpButton: Bool = true) -> Self {
        var view = self
        view.viewModifiers.hidesSignUpButton = hidesSignUpButton
        return view
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError?) -> Self {
        state.errorTransform = errorTransform
        return self
    }

    private var shouldHideSignUpButton: Bool {
        if let hidesSignUpButton = viewModifiers.hidesSignUpButton {
            return hidesSignUpButton
        }

        return options.hidesSignUpButton
    }

    private func signIn() async {
        let usernameValidation = usernameValidator.validate()
        let passwordValidation = passwordValidator.validate()

        guard usernameValidation, passwordValidation else {
            log.verbose("Some input validations failed")
            return
        }

        try? await state.signIn()
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
        #if os(iOS)
            .keyboardType(.default)
        #endif

        case .email:
            TextField(
                "authenticator.field.email.label".localized(),
                text: $state.username,
                placeholder: "authenticator.field.email.placeholder".localized(),
                validator: usernameValidator
            )
        #if os(iOS)
            .keyboardType(.emailAddress)
        #endif

        case .phoneNumber:
            PhoneNumberField(
                "authenticator.field.phoneNumber.label".localized(),
                text: $state.username,
                placeholder: "authenticator.field.phoneNumber.placeholder".localized(),
                validator: usernameValidator
            )
        #if os(iOS)
            .keyboardType(.numberPad)
        #endif
        }
    }
}

extension SignInView {
    private struct ViewModifiers {
        var hidesSignUpButton: Bool? = nil
    }
}

/// Default header for the ``SignInView``. It displays the view's title
public struct SignInHeader: View {

    /// Creates a `SignInHeader`
    public init() {}
    public var body: some View {
        DefaultHeader(
            title: "authenticator.signIn.title".localized()
        )
    }
}

/// Default footer for the ``SignInView``. It displays the navigation buttons
public struct SignInFooter: View {
    @Environment(\.authenticatorTheme) private var theme
    @Environment(\.authenticatorState) private var authenticatorState
    @Environment(\.authenticatorOptions) private var options
    @State private var authenticatorHidesSignUpButton = false

    private var shouldHideSignUpButton: Bool?

    /// Creates a `SignInFooter`
    public init() {
        self.shouldHideSignUpButton = nil
    }

    /// Creates a `SignInFooter`
    /// - Parameter hidesSignUpButton: Whether to hide the Sign Up button.
    public init(hidesSignUpButton: Bool) {
        self.shouldHideSignUpButton = hidesSignUpButton
    }

    /// Whether the Sign Up button is hidden
    public var hidesSignUpButton: Bool {
        if let hidesSignUpButton = shouldHideSignUpButton {
            return hidesSignUpButton
        }

        return authenticatorHidesSignUpButton
    }

    public var body: some View {
        HStack(spacing: theme.components.authenticator.spacing.horizontal) {
            Button("authenticator.signIn.button.forgotPassword".localized()) {
                authenticatorState.move(to: .resetPassword)
            }
            .buttonStyle(.link)

            Spacer()

            if !hidesSignUpButton {
                Button("authenticator.signIn.button.createAccount".localized()) {
                    authenticatorState.move(to: .signUp)
                }
                .buttonStyle(.link)
            }

        }
        .animation(options.contentAnimation, value: hidesSignUpButton)
        .onReceive(options.$hidesSignUpButton) { hidesSignUpButton in
            authenticatorHidesSignUpButton = hidesSignUpButton
        }
    }
}
