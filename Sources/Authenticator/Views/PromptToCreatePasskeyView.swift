//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents the content being displayed when the ``Authenticator`` is in the ``AuthenticatorStep/promptToCreatePasskey`` step.
public struct PromptToCreatePasskeyView<Header: View,
                                        Footer: View>: View {
    @Environment(\.authenticatorState) private var authenticatorState
    @Environment(\.authenticatorTheme) var theme
    @ObservedObject private var state: PromptToCreatePasskeyState
    private let headerContent: Header
    private let footerContent: Footer

    /// Creates a `PromptToCreatePasskeyView`
    /// - Parameter state: The ``PromptToCreatePasskeyState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``PromptToCreatePasskeyHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  ``PromptToCreatePasskeyFooter``
    public init(
        state: PromptToCreatePasskeyState,
        @ViewBuilder headerContent: () -> Header = {
            PromptToCreatePasskeyHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            PromptToCreatePasskeyFooter()
        }
    ) {
        self._state = ObservedObject(wrappedValue: state)
        self.headerContent = headerContent()
        self.footerContent = footerContent()
    }

    public var body: some View {
        AuthenticatorView(isBusy: state.isBusy) {
            headerContent
            
            Text("authenticator.promptToCreatePasskey.description".localized())
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.foreground.primary)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 16)

            // Passkey illustration
            Image("passkey", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .padding(.vertical, 24)

            Button("authenticator.promptToCreatePasskey.button.createPasskey".localized()) {
                Task {
                    await createPasskey()
                }
            }
            .buttonStyle(.primary)

            Button("authenticator.promptToCreatePasskey.button.skip".localized()) {
                Task {
                    await skip()
                }
            }
            .buttonStyle(.link)

            footerContent
        }
        .messageBanner($state.message)
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError?) -> Self {
        state.errorTransform = errorTransform
        return self
    }

    private func createPasskey() async {
        try? await state.createPasskey()
    }

    private func skip() async {
        try? await state.skip()
    }
}

extension PromptToCreatePasskeyView: AuthenticatorLogging {}

/// Default header for the ``PromptToCreatePasskeyView``. It displays the view's title
public struct PromptToCreatePasskeyHeader: View {
    public init() {}
    public var body: some View {
        DefaultHeader(
            title: "authenticator.promptToCreatePasskey.title".localized()
        )
    }
}

/// Default footer for the ``PromptToCreatePasskeyView``.
public struct PromptToCreatePasskeyFooter: View {
    public init() {}
    public var body: some View {
        EmptyView()
    }
}
