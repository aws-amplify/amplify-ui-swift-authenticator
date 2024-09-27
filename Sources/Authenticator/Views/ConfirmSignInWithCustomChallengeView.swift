//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents the content being displayed when the ``Authenticator`` is in the ``AuthenticatorStep/confirmSignInWithCustomChallenge`` step.
public struct ConfirmSignInWithCustomChallengeView<Header: View,
                                                   Footer: View>: View {
    @ObservedObject private var state: ConfirmSignInWithCodeState
    private let content: ConfirmSignInWithCodeView<Header, Footer>

    /// Creates a `ConfirmSignInWithCustomChallengeView`
    /// - Parameter state: The ``ConfirmSignInWithCodeState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``ConfirmSignInWithCustomChallengeHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  `SwiftUI.EmptyView`
    public init(
        state: ConfirmSignInWithCodeState,
        @ViewBuilder headerContent: () -> Header = {
            ConfirmSignInWithCustomChallengeHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            EmptyView()
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

/// Default header for the ``ConfirmSignInWithCustomChallengeView``. It displays the view's title
public struct ConfirmSignInWithCustomChallengeHeader: View {
    public init() {}
    public var body: some View {
        DefaultHeader(
            title: "authenticator.confirmSignInWithCustomChallenge.title".localized()
        )
    }
}
