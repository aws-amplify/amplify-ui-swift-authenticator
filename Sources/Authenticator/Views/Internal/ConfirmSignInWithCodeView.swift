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
        errorTransform: ((AuthError) -> AuthenticatorError)? = nil
    ) {
        self.state = state
        self.headerContent = headerContent()
        self.footerContent = footerContent()
        self._codeValidator = StateObject(wrappedValue: Validator(
            using: FieldValidators.required
        ))
    }

    var body: some View {
        AuthenticatorView(isBusy: state.isBusy) {
            headerContent

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

            Button("authenticator.confirmSignInWithCode.button.submit".localized()) {
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
