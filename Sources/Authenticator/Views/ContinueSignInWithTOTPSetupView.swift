//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI
import CoreImage.CIFilterBuiltins


/// Represents the content being displayed when the ``Authenticator`` is in the ``AuthenticatorStep/continueSignInWithTOTPSetup`` step.
public struct ContinueSignInWithTOTPSetupView<Header: View,
                                              QRCodeContent: View,
                                              CopyKeyContent: View,
                                              Footer: View>: View {
    @Environment(\.authenticatorState) private var authenticatorState
    @Environment(\.authenticatorTheme) private var theme
    @Environment(\.authenticatorOptions) private var options
    @ObservedObject private var state: ContinueSignInWithTOTPSetupState
    @StateObject private var codeValidator: Validator
    private let headerContent: Header
    private let qrCodeContent: QRCodeContent
    private let copyKeyContent: CopyKeyContent
    private let footerContent: Footer

    /// Creates a `ContinueSignInWithTOTPSetupView`
    /// - Parameter state: The ``ContinueSignInWithTOTPSetupState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``ContinueSignInWithTOTPSetupHeader``
    /// - Parameter qrCodeContent: The content displayed for the QR code. Defaults to  ``ContinueSignInWithTOTPSetupQRCodeView``
    /// - Parameter copyKeyContent: The content displayed for copying the code. Defaults to  ``ContinueSignInWithTOTPCopyKeyView``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  ``ContinueSignInWithTOTPSetupFooter``
    public init(
        state: ContinueSignInWithTOTPSetupState,
        @ViewBuilder headerContent: () -> Header = {
            ContinueSignInWithTOTPSetupHeader()
        },
        @ViewBuilder qrCodeContent: (ContinueSignInWithTOTPSetupState) -> QRCodeContent = { state in
            ContinueSignInWithTOTPSetupQRCodeView(state: state)
        },
        @ViewBuilder copyKeyContent: (ContinueSignInWithTOTPSetupState) -> CopyKeyContent = { state in
            ContinueSignInWithTOTPCopyKeyView(state: state)
        },
        @ViewBuilder footerContent: () -> Footer = {
            ContinueSignInWithTOTPSetupFooter()
        }
    ) {
        self.state = state
        self.headerContent = headerContent()
        self.qrCodeContent = qrCodeContent(state)
        self.copyKeyContent = copyKeyContent(state)
        self.footerContent = footerContent()
        self._codeValidator = StateObject(wrappedValue: Validator(
            using: FieldValidators.required
        ))
    }

    public var body: some View {
        AuthenticatorView(isBusy: state.isBusy) {

            headerContent

            Spacer()

            AuthenticatorTextWithHeader(
                title: "authenticator.continueSignInWithTOTPSetup.step1.label.title".localized(),
                content: "authenticator.continueSignInWithTOTPSetup.step1.label.content".localized()
            )

            AuthenticatorTextWithHeader(
                title: "authenticator.continueSignInWithTOTPSetup.step2.label.title".localized(),
                content: "authenticator.continueSignInWithTOTPSetup.step2.label.content".localized()
            )

            qrCodeContent

            copyKeyContent

            AuthenticatorTextWithHeader(
                title: "authenticator.continueSignInWithTOTPSetup.step3.label.title".localized(),
                content: "authenticator.continueSignInWithTOTPSetup.step3.label.content".localized()
            )

            TextField(
                "authenticator.continueSignInWithTOTPSetup.field.code.placeholder".localized(),
                text: $state.confirmationCode,
                validator: codeValidator
            )
            .textContentType(.oneTimeCode)
#if os(iOS)
            .keyboardType(.default)
#endif

            Button("authenticator.continueSignInWithTOTPSetup.button.submit".localized()) {
                Task { await continueSignIn() }
            }
            .buttonStyle(.primary)
            .disabled(state.confirmationCode.isEmpty)
            .opacity(state.confirmationCode.isEmpty ? 0.5 : 1)
            
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
        guard codeValidator.validate() else {
            log.verbose("Code validation failed")
            return
        }

        try? await state.continueSignIn()
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError) -> Self {
        state.errorTransform = errorTransform
        return self
    }
}

extension ContinueSignInWithTOTPSetupView: AuthenticatorLogging {}

/// Default header for the ``ContinueSignInWithTOTPSetupView``. It displays the view's title
public struct ContinueSignInWithTOTPSetupHeader: View {
    public init() {}
    public var body: some View {
        DefaultHeader(
            title: "authenticator.continueSignInWithTOTPSetup.title".localized()
        )
        .alignment(.center)
    }
}

/// Default footer for the ``ContinueSignInWithTOTPSetupView``. It displays the "Back to Sign In" button
public struct ContinueSignInWithTOTPSetupFooter: View {
    @Environment(\.authenticatorState) private var authenticatorState

    public init() {}
    public var body: some View {
        Button("authenticator.continueSignInWithTOTPSetup.button.backToSignIn".localized()) {
            authenticatorState.move(to: .signIn)
        }
        .buttonStyle(.link)
    }
}
