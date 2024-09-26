//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents the content being displayed when the ``Authenticator`` is in the ``AuthenticatorStep/confirmSignInWithTOTPCode`` step.
public struct ConfirmSignInWithTOTPView<Header: View,
                                        Footer: View>: View {
    @Environment(\.authenticatorState) private var authenticatorState
    @ObservedObject private var state: ConfirmSignInWithCodeState
    private let content: ConfirmSignInWithCodeView<Header, Footer>

    /// Creates a `ConfirmSignInWithTOTPView`
    /// - Parameter state: The ``ConfirmSignInWithCodeState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``ConfirmSignInWithTOTPHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  ``ConfirmSignInWithTOTPFooter``
    public init(
        state: ConfirmSignInWithCodeState,
        @ViewBuilder headerContent: () -> Header = {
            ConfirmSignInWithTOTPHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            ConfirmSignInWithTOTPFooter()
        }
    ) {
        self.state = state
        self.content = ConfirmSignInWithCodeView(
            state: state,
            headerContent: headerContent,
            footerContent: footerContent
        )
    }

    public var body: some View {
        content
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError?) -> Self {
        state.errorTransform = errorTransform
        return self
    }
}

/// Default header for the ``ConfirmSignInWithTOTPCodeView``. It displays the view's title
public struct ConfirmSignInWithTOTPHeader: View {
    public init() {}
    public var body: some View {
        DefaultHeader(
            title: "authenticator.confirmSignInWithCode.totp.title".localized()
        )
    }
}

/// Default footer for the ``ConfirmSignInWithTOTPCodeView``. It displays the "Back to Sign In" button
public struct ConfirmSignInWithTOTPFooter: View {
    @Environment(\.authenticatorState) private var authenticatorState

    public init() {}
    public var body: some View {
        Button("authenticator.confirmSignInWithCode.totp.button.backToSignIn".localized()) {
            authenticatorState.move(to: .signIn)
        }
        .buttonStyle(.link)
    }
}

