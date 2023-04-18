//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents the content being displayed when the Authenticator is in the `.confirmVerifyUser` step.
public struct ConfirmVerifyUserView<Header: View,
                                    Footer: View>: View {
    @Environment(\.authenticatorState) private var authenticatorState
    @StateObject private var codeValidator: Validator
    @ObservedObject private var state: ConfirmVerifyUserState
    private let headerContent: (AuthUserAttributeKey) -> Header
    private let footerContent: Footer

    /// Creates a `ConfirmVerifyUserView`
    /// - Parameter state: The ``ConfirmVerifyUserState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``ConfirmVerifyUserHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  `EmptyView`
    public init(
        state: ConfirmVerifyUserState,
        @ViewBuilder headerContent: @escaping (AuthUserAttributeKey) -> Header = { attribute in
            ConfirmVerifyUserHeader(attribute: attribute)
        },
        @ViewBuilder footerContent: () -> Footer = {
            EmptyView()
        }
    ) {
        self._state = ObservedObject(wrappedValue: state)
        self.headerContent = headerContent
        self.footerContent = footerContent()
        self._codeValidator = StateObject(wrappedValue: Validator(
            using: FieldValidators.required
        ))
    }

    public var body: some View {
        AuthenticatorView(isBusy: state.isBusy) {
            if let attribute = state.userAttributeKey {
                headerContent(attribute)
            }

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

            Button("authenticator.confirmVerifyUser.button.verify".localized()) {
                Task {
                    await confirmVerifyUser()
                }
            }
            .buttonStyle(.primary)

            Button("authenticator.confirmVerifyUser.button.skip".localized()) {
                Task {
                    await skip()
                }
            }
            .buttonStyle(.link)

            footerContent
        }
        .messageBanner($state.message)
        .onSubmit {
            Task {
                await confirmVerifyUser()
            }
        }
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError) -> Self {
        state.errorTransform = errorTransform
        return self
    }

    private func confirmVerifyUser() async {
        guard codeValidator.validate() else {
            log.verbose("Code validation failed")
            return
        }
        try? await state.confirmVerifyUser()
    }

    private func skip() async {
        try? await state.skip()
    }
}

extension ConfirmVerifyUserView: AuthenticatorLogging {}

/// Default header for the ``ConfirmVerifyUserView``. It displays the view's title, which contains the attribute to verify
public struct ConfirmVerifyUserHeader: View {
    /// The `AuthUserAttributeKey` that the user must verify
    public let attribute: AuthUserAttributeKey

    /// Creates a ``ConfirmVerifyUserHeader``
    /// - Parameter attribute: The ``AuthUserAttributeKey`` that the user must verify
    public init(attribute: AuthUserAttributeKey) {
        self.attribute = attribute
    }

    public var body: some View {
        DefaultHeader(
            title:
                "authenticator.confirmVerifyUser.title".localized(
                    using: attribute.localizedTitle
            )
        )
    }
}
