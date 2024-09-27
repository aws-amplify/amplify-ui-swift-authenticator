//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents the content being displayed when the ``Authenticator`` is in the ``AuthenticatorStep/continueSignInWithEmailMFASetup`` step.
public struct ContinueSignInWithEmailMFASetupView<Header: View,
                                                  Footer: View>: View {
    @Environment(\.authenticatorState) private var authenticatorState
    @ObservedObject private var state: ContinueSignInWithEmailMFASetupState
    @StateObject private var emailValidator: Validator
    private let headerContent: Header
    private let footerContent: Footer

    /// Creates a `ContinueSignInWithEmailMFASetupView`
    /// - Parameter state: The ``ContinueSignInWithEmailMFASetupState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``ContinueSignInWithEmailMFASetupHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  ``ContinueSignInWithEmailMFASetupFooter``
    public init(
        state: ContinueSignInWithEmailMFASetupState,
        @ViewBuilder headerContent: () -> Header = {
            ContinueSignInWithEmailMFASetupHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            ContinueSignInWithEmailMFASetupFooter()
        }
    ) {
        self.headerContent = headerContent()
        self.footerContent = footerContent()
        self.state = state
        self._emailValidator = StateObject(wrappedValue: Validator(
            using: FieldValidators.email
        ))
    }

    private var textFieldLabel: String {
        return "authenticator.continueSignInWithEmailMFASetup.field.email.label".localized()
    }

    private var textFieldPlaceholder: String {
        return "authenticator.field.email.placeholder".localized()
    }

    private var continueButtonTitle: String {
        return "authenticator.continueSignInWithEmailMFASetup.button.continue".localized()
    }

    public var body: some View {
        AuthenticatorView(isBusy: state.isBusy) {
            headerContent

            TextField(
                textFieldLabel,
                text: $state.email,
                placeholder: textFieldPlaceholder,
                validator: emailValidator
            )
#if os(iOS)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
#endif

            Button(continueButtonTitle) {
                Task { await continueSignIn() }
            }
            .buttonStyle(.primary)

            footerContent
        }
        .messageBanner($state.message)
        .onSubmit {
            Task {
                await continueSignIn()
            }
        }
    }

    private func continueSignIn() async {
        guard emailValidator.validate() else {
            log.verbose("Email validation failed")
            return
        }

        try? await state.continueSignIn()
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError?) -> Self {
        state.errorTransform = errorTransform
        return self
    }
}

/// Default header for the ``ContinueSignInWithEmailMFASetupView``. It displays the view's title
public struct ContinueSignInWithEmailMFASetupHeader: View {
    public init() {}
    public var body: some View {
        DefaultHeader(
            title: "authenticator.continueSignInWithEmailMFASetup.title".localized()
        )
    }
}

/// Default footer for the ``ContinueSignInWithEmailMFASetupView``. It displays the "Back to Sign In" button
public struct ContinueSignInWithEmailMFASetupFooter: View {
    @Environment(\.authenticatorState) private var authenticatorState

    public init() {}
    public var body: some View {
        Button("authenticator.continueSignInWithEmailMFASetup.button.backToSignIn".localized()) {
            authenticatorState.move(to: .signIn)
        }
        .buttonStyle(.link)
    }
}

extension ContinueSignInWithEmailMFASetupView: AuthenticatorLogging {}
