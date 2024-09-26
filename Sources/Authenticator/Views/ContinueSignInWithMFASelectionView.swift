//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents the content being displayed when the ``Authenticator`` is in the ``AuthenticatorStep/continueSignInWithMFASelection`` step.
public struct ContinueSignInWithMFASelectionView<Header: View,
                                                 Footer: View>: View {
    @Environment(\.authenticatorState) private var authenticatorState
    @ObservedObject private var state: ContinueSignInWithMFASelectionState
    @Environment(\.authenticatorTheme) private var theme

    private let headerContent: Header
    private let footerContent: Footer
    
    /// Creates a `ContinueSignInWithMFASelectionView`
    /// - Parameter state: The ``ConfirmSignInWithCodeState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``ConfirmSignInWithMFASelectionHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  ``ConfirmSignInWithMFASelectionFooter``
    public init(
        state: ContinueSignInWithMFASelectionState,
        @ViewBuilder headerContent: () -> Header = {
            ConfirmSignInWithMFASelectionHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            ConfirmSignInWithMFASelectionFooter()
        }
    ) {
        self.state = state
        self.headerContent = headerContent()
        self.footerContent = footerContent()
    }
    
    public var body: some View {
        AuthenticatorView(isBusy: state.isBusy) {
            headerContent

            SwiftUI.Text("authenticator.continueSignInWithMFASelection.subtitle".localized())
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.foreground.primary)
                .accessibilityAddTraits(.isStaticText)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)


            /// Only add TOTP option if it is allowed for selection by the service
            if(state.allowedMFATypes.contains(.totp)) {
                RadioButton(
                    label: "authenticator.continueSignInWithMFASelection.totp.radioButton.title".localized(),
                    isSelected: .constant(state.selectedMFAType == .totp)
                ) {
                    state.selectedMFAType = .totp
                }
                .accessibilityAddTraits(state.selectedMFAType == .totp ? .isSelected : .isButton)
                .animation(.none, value: state.selectedMFAType)
            }

            /// Only add SMS option if it is allowed for selection by the service
            if(state.allowedMFATypes.contains(.sms)) {
                RadioButton(
                    label: "authenticator.continueSignInWithMFASelection.sms.radioButton.title".localized(),
                    isSelected: .constant(state.selectedMFAType == .sms)
                ) {
                    state.selectedMFAType = .sms
                }
                .accessibilityAddTraits(state.selectedMFAType == .sms ? .isSelected : .isButton)
                .animation(.none, value: state.selectedMFAType)
            }

            /// Only add Email option if it is allowed selection by the service
            if state.allowedMFATypes.contains(.email) {
                RadioButton(
                    label: "authenticator.continueSignInWithMFASelection.email.radioButton.title".localized(),
                    isSelected: .constant(state.selectedMFAType == .email)
                ) {
                    state.selectedMFAType = .email
                }
                .accessibilityAddTraits(state.selectedMFAType == .email ? .isSelected : .isButton)
                .animation(.none, value: state.selectedMFAType)
            }

            Button("authenticator.continueSignInWithMFASelection.button.submit".localized()) {
                Task { await continueSignIn() }
            }
            .buttonStyle(.primary)
            .disabled(state.selectedMFAType == nil)
            .opacity(state.selectedMFAType == nil ? 0.5 : 1)

            footerContent
        }
        .messageBanner($state.message)
        .onSubmit {
            Task {
                await continueSignIn()
            }
        }
        .onDisappear{
            state.selectedMFAType = nil
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

extension ContinueSignInWithMFASelectionView: AuthenticatorLogging {}

/// Default header for the ``ContinueSignInWithMFASelectionView``. It displays the view's title
public struct ConfirmSignInWithMFASelectionHeader: View {
    public init() {}
    public var body: some View {
        DefaultHeader(
            title: "authenticator.continueSignInWithMFASelection.title".localized()
        )
    }
}

/// Default footer for the ``ContinueSignInWithMFASelectionView``. It displays the "Back to Sign In" button
public struct ConfirmSignInWithMFASelectionFooter: View {
    @Environment(\.authenticatorState) private var authenticatorState
    
    public init() {}
    public var body: some View {
        Button("authenticator.continueSignInWithMFASelection.button.backToSignIn".localized()) {
            authenticatorState.move(to: .signIn)
        }
        .buttonStyle(.link)
    }
}

