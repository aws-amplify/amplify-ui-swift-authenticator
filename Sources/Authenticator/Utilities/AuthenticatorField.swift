//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

struct AuthenticatorField<Content: View>: View {
    @Environment(\.isEnabled) private var isEnabled: Bool
    private var isFocused: Bool
    @Environment(\.authenticatorOptions) private var options
    @Environment(\.authenticatorTheme) var theme
    @ObservedObject private var validator: Validator
    private let label: String?
    private let placeholder: String
    private let content: Content

    init(_ label: String?,
         placeholder: String,
         validator: Validator,
         isFocused: Bool,
         content: () -> Content) {
        self.label = label
        self.placeholder = placeholder
        self.validator = validator
        self.isFocused = isFocused
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.components.field.spacing.vertical) {
            if let label = label {
                SwiftUI.Text(label)
                    .foregroundColor(foregroundColor)
                    .font(theme.fonts.body)
                    .accessibilityHidden(true)
            }

            content
            .background(
                RoundedRectangle(cornerRadius: theme.components.field.cornerRadius, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.components.field.cornerRadius)
                    .stroke(borderColor,
                            lineWidth: borderWidth)

            )

            if let errorMessage = errorMessage {
                SwiftUI.Text(errorMessage)
                    .font(theme.fonts.subheadline)
                    .foregroundColor(foregroundColor)
                    .transition(options.contentTransition)
                    .accessibilityHidden(true)
            }

        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel)
        .animation(options.contentAnimation, value: validator.state)
    }

    private var backgroundColor: Color {
        isEnabled ? theme.components.field.backgroundColor : Color(
            light: theme.colors.background.disabled,
            dark: .clear
        )
    }

    private var foregroundColor: Color {
        switch validator.state {
        case .normal:
            return theme.colors.foreground.secondary
        case .error:
            return theme.colors.foreground.error
        }
    }

    private var borderColor: Color {
        switch validator.state {
        case .normal:
            return isFocused ?
                theme.colors.border.interactive : theme.colors.border.primary

        case .error:
            return theme.colors.border.error
        }
    }

    private var borderWidth: CGFloat {
        let width = theme.components.field.borderWidth
        return isFocused ? width + 1 : width
    }

    private var title: String {
        return label ?? placeholder
    }

    private var errorMessage: String? {
        if case .error(let message) = validator.state,
            let message = message {
            return String(format: message, title)
        }
        return nil
    }

    private var accessibilityLabel: Text {
        if let errorMessage = errorMessage {
            return Text("\(errorMessage). \(title)")
        }

        return Text(title)
    }
}
