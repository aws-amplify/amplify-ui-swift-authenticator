//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

struct AuthenticatorView<Content: View>: View {
    @Environment(\.authenticatorTheme) private var theme
    @Environment(\.authenticatorOptions) private var options
    private var isBusy: Bool
    private let content: Content

    init(isBusy: Bool, @ViewBuilder content: () -> Content) {
        self.isBusy = isBusy
        self.content = content()
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: theme.components.authenticator.spacing.vertical) {
                    content
                }
                .padding(theme.components.authenticator.padding/2)
                .background(theme.components.authenticator.backgroundColor)
                .cornerRadius(theme.components.authenticator.cornerRadius)
                .padding(theme.components.authenticator.padding/2)
            }
            .blur(radius: isBusy ? options.busyStyle.blurRadius : 0)
            .disabled(isBusy)

            if isBusy {
                AnyView(options.busyStyle.content)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
