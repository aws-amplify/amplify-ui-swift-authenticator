//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

struct AuthenticatorView<Content: View>: View {
    @Environment(\.authenticatorTheme) private var theme
    private var isBusy: Bool
    private let content: Content

    init(isBusy: Bool, @ViewBuilder content: () -> Content) {
        self.isBusy = isBusy
        self.content = content()
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: theme.Authenticator.spacing.vertical) {
                    content
                }
                .padding(theme.Authenticator.style.padding/2)
                .background(theme.Authenticator.style.backgroundColor)
                .cornerRadius(theme.Authenticator.style.cornerRadius)
                .padding(theme.Authenticator.style.padding/2)
            }
            .blur(radius: isBusy ? theme.Authenticator.loadingBlur : 0)
            .disabled(isBusy)

            if isBusy {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
