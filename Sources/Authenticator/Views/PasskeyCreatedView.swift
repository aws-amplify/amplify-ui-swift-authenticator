//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents the content being displayed when the ``Authenticator`` is in the ``AuthenticatorStep/passkeyCreated`` step.
public struct PasskeyCreatedView<Header: View,
                                 Footer: View>: View {
    @Environment(\.authenticatorState) private var authenticatorState
    @Environment(\.authenticatorTheme) var theme
    @ObservedObject private var state: PasskeyCreatedState
    private let headerContent: Header
    private let footerContent: Footer

    /// Creates a `PasskeyCreatedView`
    /// - Parameter state: The ``PasskeyCreatedState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``PasskeyCreatedHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  ``PasskeyCreatedFooter``
    public init(
        state: PasskeyCreatedState,
        @ViewBuilder headerContent: () -> Header = {
            PasskeyCreatedHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            PasskeyCreatedFooter()
        }
    ) {
        self._state = ObservedObject(wrappedValue: state)
        self.headerContent = headerContent()
        self.footerContent = footerContent()
    }

    public var body: some View {
        AuthenticatorView(isBusy: state.isBusy) {
            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(.green)
                .padding(.top, 24)
                .padding(.bottom, 8)
            
            Text("authenticator.passkeyCreated.message".localized())
                .font(theme.fonts.title)
                .foregroundColor(theme.colors.foreground.primary)
                .padding(.bottom, 16)
            
            // Existing passkeys section
            if !state.passkeyCredentials.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("authenticator.passkeyCreated.existingPasskeys".localized())
                        .font(theme.fonts.subheadline)
                        .foregroundColor(theme.colors.foreground.secondary)
                    
                    ForEach(state.passkeyCredentials, id: \.credentialId) { credential in
                        HStack {
                            Text(credential.friendlyName ?? "authenticator.passkeyCreated.unknowName".localized())
                                .font(theme.fonts.body)
                                .foregroundColor(theme.colors.foreground.primary)
                            Spacer()
                        }
                        .padding()
                        .background(theme.colors.background.secondary)
                        .cornerRadius(8)
                    }
                }
                .padding(.bottom, 24)
            }

            Button("authenticator.passkeyCreated.button.continue".localized()) {
                Task {
                    await continueFlow()
                }
            }
            .buttonStyle(.primary)

            footerContent
        }
        .messageBanner($state.message)
        .onAppear {
            Task {
                await state.fetchPasskeyCredentials()
            }
        }
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError?) -> Self {
        state.errorTransform = errorTransform
        return self
    }

    private func continueFlow() async {
        try? await state.continue()
    }
}

extension PasskeyCreatedView: AuthenticatorLogging {}

/// Default header for the ``PasskeyCreatedView``.
public struct PasskeyCreatedHeader: View {
    public init() {}
    public var body: some View {
        EmptyView()
    }
}

/// Default footer for the ``PasskeyCreatedView``.
public struct PasskeyCreatedFooter: View {
    public init() {}
    public var body: some View {
        EmptyView()
    }
}
