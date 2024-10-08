//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

struct ConfirmSignInWithCodeView<Header: View,
                                 Footer: View>: View {
    @Environment(\.authenticatorState) private var authenticatorState
    @StateObject private var codeValidator: Validator
    @ObservedObject private var state: ConfirmSignInWithCodeState
    private let mfaType: AuthenticatorMFAType
    private let headerContent: Header
    private let footerContent: Footer

    init(
        state: ConfirmSignInWithCodeState,
        @ViewBuilder headerContent: () -> Header = {
            EmptyView()
        },
        @ViewBuilder footerContent: () -> Footer = {
            EmptyView()
        },
        errorTransform: ((AuthError) -> AuthenticatorError?)? = nil,
        mfaType: AuthenticatorMFAType
    ) {
        self.state = state
        self.headerContent = headerContent()
        self.footerContent = footerContent()
        self._codeValidator = StateObject(wrappedValue: Validator(
            using: FieldValidators.required
        ))
        self.mfaType = mfaType
    }

    private var textFieldLabel: String {
        switch mfaType {
        case .sms, .none:
            return "authenticator.field.code.label".localized()
        case .totp:
            return "authenticator.field.totp.code.label".localized()
        }
    }

    private var textFieldPlaceholder: String {
        switch mfaType {
        case .sms, .none:
            return "authenticator.field.code.placeholder".localized()
        case .totp:
            return "authenticator.field.totp.code.placeholder".localized()
        }
    }

    private var submitButtonTitle: String {
        switch mfaType {
        case .sms, .none:
            return "authenticator.confirmSignInWithCode.button.submit".localized()
        case .totp:
            return "authenticator.confirmSignInWithCode.totp.button.submit".localized()
        }
    }

    var body: some View {
        AuthenticatorView(isBusy: state.isBusy) {
            headerContent

            TextField(
                textFieldLabel,
                text: $state.confirmationCode,
                placeholder: textFieldPlaceholder,
                validator: codeValidator
            )
            .textContentType(.oneTimeCode)
        #if os(iOS)
            .keyboardType(.default)
        #endif

            Button(submitButtonTitle) {
                Task { await confirmSignIn() }
            }
            .buttonStyle(.primary)

            footerContent
        }
        .messageBanner($state.message)
        .onSubmit {
            Task {
                await confirmSignIn()
            }
        }
    }

    private func confirmSignIn() async {
        guard codeValidator.validate() else {
            log.verbose("Code validation failed")
            return
        }

        try? await state.confirmSignIn()
    }
}

extension ConfirmSignInWithCodeView: AuthenticatorLogging {}
