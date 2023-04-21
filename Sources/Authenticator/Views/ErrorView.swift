//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

/// Represents the content being displayed when the ``Authenticator`` is in the ``AuthenticatorStep/error`` step.
public struct ErrorView: View {
    @Environment(\.authenticatorTheme) private var theme

    public init() {}

    public var body: some View {
        AuthenticatorView(isBusy: false) {
            DefaultHeader(
                title: "authenticator.authenticatorError.title".localized()
            )
            .foregroundColor(theme.Colors.Border.error)
            
            SwiftUI.Text("authenticator.authenticatorError.message".localized())
                .foregroundColor(theme.Colors.Foreground.error)
            
            Spacer()
        }
    }
}
