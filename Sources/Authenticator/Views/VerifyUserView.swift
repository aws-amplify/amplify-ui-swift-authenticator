//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents the content being displayed when the Authenticator is in the `.verifyUser` step.
public struct VerifyUserView<Header: View,
                             Footer: View>: View {
    @Environment(\.authenticatorState) private var authenticatorState
    @ObservedObject private var state: VerifyUserState
    private let headerContent: Header
    private let footerContent: Footer

    /// Creates a `VerifyUserView`
    /// - Parameter state: The ``VerifyUserState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``VerifyUserHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  `EmptyView`
    public init(
        state: VerifyUserState,
        @ViewBuilder headerContent: () -> Header = {
            VerifyUserHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            EmptyView()
        }
    ) {
        self._state = ObservedObject(wrappedValue: state)
        self.headerContent = headerContent()
        self.footerContent = footerContent()
    }

    public var body: some View {
        AuthenticatorView(isBusy: state.isBusy) {
            headerContent

            ForEach(state.unverifiedFields, id: \.self) { field in
                RadioButton(
                    label: field.localizedTitle,
                    isSelected: .constant(state.selectedField == field)
                ) {
                    state.selectedField = field
                }
                .accessibilityAddTraits(state.selectedField == field ? .isSelected : .isButton)
                .animation(.none, value: state.selectedField)
            }

            Button("authenticator.verifyUser.button.verify".localized()) {
                Task {
                    await verifyUser()
                }
            }
            .buttonStyle(.primary)
            .disabled(state.selectedField == nil)
            .opacity(state.selectedField == nil ? 0.5 : 1)

            Button("authenticator.verifyUser.button.skip".localized()) {
                Task {
                    await skip()
                }
            }
            .buttonStyle(.link)
            
            footerContent
        }
        .messageBanner($state.message)
        .task {
            // If we somehow ended up in this view with no attributes to verify, automatically skip
            if state.unverifiedFields.isEmpty {
                await skip()
            }
        }
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError) -> Self {
        state.errorTransform = errorTransform
        return self
    }

    private func verifyUser() async {
        try? await state.verifyUser()
    }

    private func skip() async {
        try? await state.skip()
    }
}

/// Default header for the ``VerifyUserView``. It displays the view's title
public struct VerifyUserHeader: View {
    @Environment(\.authenticatorTheme) private var theme

    public init() {}
    public var body: some View {
        DefaultHeader(
            title: "authenticator.verifyUser.title".localized()
        )
        .font(theme.Fonts.title3)
    }
}
