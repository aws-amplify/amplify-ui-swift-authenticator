//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents the content being displayed when the ``Authenticator`` is in the ``AuthenticatorStep/continueSignInWithMFASetupSelection`` step.
public struct ContinueSignInWithMFASetupSelectionView<Header: View,
                                                      Footer: View>: View {
    @Environment(\.authenticatorState) private var authenticatorState
    @ObservedObject private var state: ContinueSignInWithMFASetupSelectionState

    @Environment(\.authenticatorTheme) private var theme
    private let headerContent: Header
    private let footerContent: Footer

    /// Creates a `ContinueSignInWithMFASetupSelectionView`
    /// - Parameter state: The ``ContinueSignInWithMFASetupSelectionState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``ContinueSignInWithMFASetupSelectionHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  ``ContinueSignInWithMFASetupSelectionFooter``
    public init(
        state: ContinueSignInWithMFASetupSelectionState,
        @ViewBuilder headerContent: () -> Header = {
            ContinueSignInWithMFASetupSelectionHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            ContinueSignInWithMFASetupSelectionFooter()
        }
    ) {
        self.state = state
        self.headerContent = headerContent()
        self.footerContent = footerContent()
    }

    public var body: some View {
        AuthenticatorView(isBusy: state.isBusy) {
            headerContent

            SwiftUI.Text("authenticator.continueSignInWithMFASetupSelection.body".localized())
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.foreground.primary)
                .accessibilityAddTraits(.isStaticText)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            /// Only add TOTP option if it is allowed for setup selection by the service
            if state.allowedMFATypes.contains(.totp) {
                RadioButton(
                    label: "authenticator.continueSignInWithMFASelection.totp.radioButton.title".localized(),
                    isSelected: .constant(state.selectedMFATypeToSetup == .totp)
                ) {
                    state.selectedMFATypeToSetup = .totp
                }
                .accessibilityAddTraits(state.selectedMFATypeToSetup == .totp ? .isSelected : .isButton)
                .animation(.none, value: state.selectedMFATypeToSetup)
            }

            /// Only add Email option if it is allowed for setup selection by the service
            if state.allowedMFATypes.contains(.email) {
                RadioButton(
                    label: "authenticator.continueSignInWithMFASetupSelection.email.radioButton.title".localized(),
                    isSelected: .constant(state.selectedMFATypeToSetup == .email)
                ) {
                    state.selectedMFATypeToSetup = .email
                }
                .accessibilityAddTraits(state.selectedMFATypeToSetup == .email ? .isSelected : .isButton)
                .animation(.none, value: state.selectedMFATypeToSetup)
            }

            Button("authenticator.continueSignInWithMFASetupSelection.button.continue".localized()) {
                Task { await continueSignIn() }
            }
            .buttonStyle(.primary)
            .disabled(state.selectedMFATypeToSetup == nil)
            .opacity(state.selectedMFATypeToSetup == nil ? 0.5 : 1)

            footerContent
        }
        .messageBanner($state.message)
        .onSubmit {
            Task {
                await continueSignIn()
            }
        }
        .onDisappear {
            state.selectedMFATypeToSetup = nil
        }
    }

    private func continueSignIn() async {
        try? await state.continueSignIn()
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError?) -> Self {
        state.errorTransform = errorTransform
        return self
    }
}

extension ContinueSignInWithMFASetupSelectionView: AuthenticatorLogging {}

/// Default header for the ``ContinueSignInWithMFASetupSelectionView``. It displays the view's title
public struct ContinueSignInWithMFASetupSelectionHeader: View {
    public init() {}
    public var body: some View {
        DefaultHeader(
            title: "authenticator.continueSignInWithMFASetupSelection.title".localized()
        )
    }
}

/// Default footer for the ``ContinueSignInWithMFASetupSelectionView``. It displays the "Back to Sign In" button
public struct ContinueSignInWithMFASetupSelectionFooter: View {
    @Environment(\.authenticatorState) private var authenticatorState

    public init() {}
    public var body: some View {
        Button("authenticator.continueSignInWithMFASetupSelection.button.backToSignIn".localized()) {
            authenticatorState.move(to: .signIn)
        }
        .buttonStyle(.link)
    }
}
