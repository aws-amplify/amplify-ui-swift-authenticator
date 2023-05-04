//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

/// This represents a simple Button with a Radio Button-like look.
/// It automatically toggles its state on tap
struct RadioButton: View {
    @Environment(\.authenticatorTheme) var theme
    @Binding private var isSelected: Bool
    private let label: String
    private let action: () -> ()

    init(
        label: String,
        isSelected: Binding<Bool>,
        action: @escaping () -> ()
    ) {
        self.label = label
        self._isSelected = isSelected
        self.action = action
    }

    var body: some View {
        SwiftUI.Button(
            action: {
                isSelected.toggle()
                action()
            },
            label: {
                HStack(alignment: .center) {
                    SwiftUI.Image(
                        systemName: isSelected
                        ? "circle.inset.filled"
                        : "circle"
                    )
                    .font(.system(size: 24))
                    .foregroundColor(foregroundColor)
                    Text(label)
                        .foregroundColor(theme.colors.foreground.primary)
                    Spacer()
                }
            }
        )
    }

    private var foregroundColor: Color {
        if isSelected {
            return theme.colors.background.interactive
        }

        return theme.colors.border.primary
    }
}
