//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

/// This Button follows Amplify UI theming.
struct Button: View {
    @Environment(\.authenticatorTheme) var theme
    private var viewModifiers = ViewModifiers()
    let action: () -> Void
    let label: String

    init(
        _ label: String,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.action = action
    }

    var body: some View {
        SwiftUI.Button(label, action: action)
            .buttonStyle(buttonStyle)
    }

    private var backgroundColor: Color {
        switch viewModifiers.style {
        case .primary:
            return theme.colors.background.interactive
        case .link, .capsule:
            return .clear
        default:
            return theme.colors.background.error
        }
    }

    private var foregroundColor: Color {
        switch viewModifiers.style {
        case .primary:
            return theme.colors.foreground.inverse
        case .link, .capsule:
            return theme.colors.foreground.interactive
        default:
            return theme.colors.foreground.primary
        }
    }

    private var cornerRadius: CGFloat {
        switch viewModifiers.style {
        case .primary:
            return theme.components.button.primary.cornerRadius
        case .link:
            return theme.components.button.link.cornerRadius
        case .capsule:
            return theme.components.button.capsule.cornerRadius
        default:
            return theme.components.authenticator.cornerRadius
        }
    }

    private var borderColor: Color {
        switch viewModifiers.style {
        case .default, .capsule:
            return theme.colors.border.interactive
        default:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        switch viewModifiers.style {
        case .default, .capsule:
            return theme.components.authenticator.borderWidth
        default:
            return 0
        }
    }

    private var font: Font {
        switch viewModifiers.style {
        case .primary:
            return theme.components.button.primary.font
        case .link:
            return theme.components.button.link.font
        case .capsule:
            return theme.components.button.capsule.font
        default:
            return theme.fonts.body
        }
    }

    private var maxWidth: CGFloat? {
        switch viewModifiers.style {
        case .capsule:
            return nil
        default:
            return viewModifiers.frame.maxWidth
        }
    }

    private var padding: AuthenticatorTheme.Padding? {
        switch viewModifiers.style {
        case .primary:
            return theme.components.button.primary.padding
        case .link:
            return theme.components.button.link.padding
        case .capsule:
            return theme.components.button.capsule.padding
        default:
            return theme.components.authenticator.padding
        }
    }

    private var buttonStyle: some ButtonStyle {
        return AuthenticatorButtonStyle(
            font: font,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            padding: padding,
            maxWidth: maxWidth,
            borderWidth: borderWidth,
            borderColor: borderColor,
            useOverlay: viewModifiers.style == .capsule
        )
    }
}

extension Button {
    private struct ViewModifiers {
        var frame = Frame()
        var style: Style = .default

        struct Border {
            var color: Color = .primary
            var width: CGFloat = 1
        }

        struct Frame {
            var minWidth: CGFloat? = nil
            var idealWidth: CGFloat? = nil
            var maxWidth: CGFloat? = .infinity
            var minHeight: CGFloat? = nil
            var idealHeight: CGFloat? = nil
            var maxHeight: CGFloat? = nil
            var alignment: Alignment = .center
        }
    }

    enum Style {
        case `default`
        case primary
        case link
        case capsule
    }

    func frame(
        minWidth: CGFloat? = nil,
        idealWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        idealHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil,
        alignment: Alignment = .center
    ) -> Button {
        var view = self
        view.viewModifiers.frame.minWidth = minWidth
        view.viewModifiers.frame.idealWidth = idealWidth
        view.viewModifiers.frame.maxWidth = maxWidth
        view.viewModifiers.frame.minHeight = minHeight
        view.viewModifiers.frame.idealHeight = idealHeight
        view.viewModifiers.frame.maxHeight = maxHeight
        view.viewModifiers.frame.alignment = alignment
        return view
    }

    func buttonStyle(_ buttonStyle: Button.Style) -> Button {
        var view = self
        view.viewModifiers.style = buttonStyle
        return view
    }
}

private struct AuthenticatorButtonStyle: ButtonStyle {
    let font: Font
    let foregroundColor: Color
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let padding: AuthenticatorTheme.Padding?
    let maxWidth: CGFloat?
    let borderWidth: CGFloat
    let borderColor: Color
    let useOverlay: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        if useOverlay {
            configuration.label
                .font(font)
                .padding(padding)
                .multilineTextAlignment(.center)
                .frame(maxWidth: maxWidth)
                .foregroundColor(configuration.isPressed ? foregroundColor.opacity(0.5) : foregroundColor)
                .background(configuration.isPressed ? backgroundColor.opacity(0.5) : backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: .infinity)
                        .stroke(borderColor,
                                lineWidth: borderWidth)
                )
        } else {
            configuration.label
                .font(font)
                .padding(padding)
                .multilineTextAlignment(.center)
                .frame(maxWidth: maxWidth)
                .foregroundColor(configuration.isPressed ? foregroundColor.opacity(0.5) : foregroundColor)
                .background(configuration.isPressed ? backgroundColor.opacity(0.5) : backgroundColor)
                .cornerRadius(cornerRadius)
                .border(borderColor, width: borderWidth)
        }

    }
}
