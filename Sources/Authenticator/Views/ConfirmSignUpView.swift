//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents the content being displayed when the ``Authenticator`` is in the ``AuthenticatorStep/confirmSignUp`` step.
public struct ConfirmSignUpView<Header: View,
                                Footer: View>: View {
    @Environment(\.authenticatorState) private var authenticatorState
    @Environment(\.authenticatorTheme) var theme
    @StateObject private var codeValidator: Validator
    @ObservedObject private var state: ConfirmSignUpState
    private let headerContent: Header
    private let footerContent: Footer

    /// Creates a `ConfirmSignUpView`
    /// - Parameter state: The ``ConfirmSignUpState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``ConfirmSignUpHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  ``ConfirmSignUpFooter``
    public init(
        state: ConfirmSignUpState,
        @ViewBuilder headerContent: () -> Header = {
            ConfirmSignUpHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            ConfirmSignUpFooter()
        }
    ) {
        self._state = ObservedObject(wrappedValue: state)
        self.headerContent = headerContent()
        self.footerContent = footerContent()
        self._codeValidator = StateObject(wrappedValue: Validator(
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

            TextField(
                "authenticator.field.code.label".localized(),
                text: $state.confirmationCode,
                placeholder: "authenticator.field.code.placeholder".localized(),
                validator: codeValidator
            )
            .textContentType(.oneTimeCode)
        #if os(iOS)
            .keyboardType(.default)
        #endif

            HStack(alignment: .center) {
                Text("authenticator.confirmSignUp.lostCode".localized())
                    .font(theme.Fonts.body)
                Spacer()
                Button("authenticator.confirmSignUp.button.sendCode".localized()) {
                    Task {
                        await sendCode()
                    }
                }
                .buttonStyle(.link)
                .frame(maxWidth: nil)
            }

            Button("authenticator.confirmSignUp.button.submit".localized()) {
                Task {
                    await confirmSignUp()
                }
            }
            .buttonStyle(.primary)

            footerContent
        }
        .messageBanner($state.message)
        .onAppear {
            state.message = .info(
                message: state.localizedMessage(for: state.deliveryDetails)
            )
        }
        .onSubmit {
            Task {
                await confirmSignUp()
            }
        }
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError) -> Self {
        state.errorTransform = errorTransform
        return self
    }

    private func confirmSignUp() async {
        guard codeValidator.validate() else {
            log.verbose("Code validation failed")
            return
        }

        try? await state.confirmSignUp()
    }

    private func sendCode() async {
        try? await state.sendCode()
    }
}

extension ConfirmSignUpView: AuthenticatorLogging {}

/// Default header for the ``ConfirmSignUpView``. It displays the view's title
public struct ConfirmSignUpHeader: View {
    public init() {}
    public var body: some View {
        DefaultHeader(
            title: "authenticator.confirmSignUp.title".localized()
        )
    }
}

/// Default footer for the ``ConfirmSignUpView``. It displays the "Back to Sign In" button
public struct ConfirmSignUpFooter: View {
    @Environment(\.authenticatorState) private var authenticatorState

    public init() {}
    public var body: some View {
        Button("authenticator.confirmSignUp.button.backToSignIn".localized()) {
            authenticatorState.move(to: .signIn)
        }
        .buttonStyle(.link)
    }
}
