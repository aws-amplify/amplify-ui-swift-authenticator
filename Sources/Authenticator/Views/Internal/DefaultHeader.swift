//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

struct DefaultHeader: View {
    @Environment(\.authenticatorTheme) private var theme
    var title: String
    private var font: Font? = nil
    private var foregroundColor: Color? = nil

    init(title: String) {
        self.title = title
    }

    var body: some View {
        HStack {
            SwiftUI.Text(title)
                .font(font ?? theme.Fonts.title)
                .foregroundColor(foregroundColor ?? theme.Colors.Foreground.primary)
            .accessibilityAddTraits(.isHeader)
            Spacer()
        }
    }

    func font(_ font: Font) -> DefaultHeader {
        var view = self
        view.font = font
        return view
    }

    func foregroundColor(_ foregroundColor: Color) -> DefaultHeader {
        var view = self
        view.foregroundColor = foregroundColor
        return view
    }
}
