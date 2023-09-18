//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

struct AuthenticatorTextWithHeader: View {
    @Environment(\.authenticatorTheme) private var theme
    var title: String
    var content: String

    init(title: String, content: String) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack {
            
            SwiftUI.Text(title)
                .font(theme.fonts.headline)
                .foregroundColor(theme.colors.foreground.primary)
                .accessibilityAddTraits(.isStaticText)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 10)

            SwiftUI.Text(content)
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.foreground.primary)
                .accessibilityAddTraits(.isStaticText)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
    }

}
