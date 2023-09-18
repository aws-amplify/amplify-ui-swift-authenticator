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
                                              Footer: View>: View {
    @Environment(\.authenticatorState) private var authenticatorState
    @Environment(\.authenticatorTheme) private var theme
    @ObservedObject private var state: ConfirmSignInWithCodeState
    @StateObject private var codeValidator: Validator
    private let issuer: String?
    private let headerContent: Header
    private let footerContent: Footer

    /// Creates a `ConfirmSignInWithTOTPView`
    /// - Parameter state: The ``ConfirmSignInWithCodeState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``ContinueSignInWithTOTPSetupHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  ``ContinueSignInWithTOTPSetupFooter``
    public init(
        state: ConfirmSignInWithCodeState,
        issuer: String?,
        @ViewBuilder headerContent: () -> Header = {
            ContinueSignInWithTOTPSetupHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            ContinueSignInWithTOTPSetupFooter()
        }
    ) {
        self.state = state
        self.issuer = issuer
        self.headerContent = headerContent()
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

            // If the TOTP details were returned, build the QR Code and the button
            if let totpSetupDetails = state.totpSetupDetails {

                if let qrCodeURI = try? totpSetupDetails.getSetupURI(appName: issuer ?? Bundle.main.applicationName ?? "").absoluteString,
                   let qrCodeImage = generateQRCode(from: qrCodeURI) {
                    Image(decorative: qrCodeImage, scale: 1)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: theme.components.authenticator.qrCodeSize,
                               height: theme.components.authenticator.qrCodeSize)
                }

                Button("authenticator.continueSignInWithTOTPSetup.button.copyKey".localized()) {
#if os(iOS)
                    UIPasteboard.general.string = totpSetupDetails.sharedSecret
#elseif os(macOS)
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(totpSetupDetails.sharedSecret, forType: .string)
#endif
                }
                .buttonStyle(.capsule)

            }

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
                Task { await confirmSignIn() }
            }
            .buttonStyle(.primary)
            .disabled(state.confirmationCode.isEmpty)
            .opacity(state.confirmationCode.isEmpty ? 0.5 : 1)
            
            footerContent
        }
        .messageBanner($state.message)
        .onSubmit {
            Task {
                await confirmSignIn()
            }
        }

    }

    private func generateQRCode(from string: String) -> CGImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        guard let outputImage = filter.outputImage else {
            return nil
        }
        return CIContext().createCGImage(outputImage, from: outputImage.extent)
    }
    
    private func confirmSignIn() async {
        guard codeValidator.validate() else {
            log.verbose("Code validation failed")
            return
        }

        try? await state.confirmSignIn()
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

