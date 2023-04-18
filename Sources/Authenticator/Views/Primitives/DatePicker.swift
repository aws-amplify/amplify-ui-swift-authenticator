//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

/// This field allows the user to select a Date and parse it to a ISO-8601 format.
/// It displays a label and a "Select date" button, which when tapped shows a native DatePicker
/// This is done in order to allow not selecting anything, which the native component doesn't
struct DatePicker: View {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.authenticatorOptions) private var options
    @Environment(\.authenticatorTheme) var theme
    @ObservedObject private var validator: Validator
    @State private var selectedDate: Date = .now
    @State private var actualDate: Date? = nil
    @FocusState private var isFocused: Bool
    @Binding private var text: String
    private let label: String
    private let formatter = ISO8601DateFormatter()

    init(_ label: String,
         text: Binding<String>,
         validator: Validator? = nil) {
        self.label = label
        self._text = text

        self.validator = validator ?? .init(
            using: FieldValidators.none
        )
        self.validator.value = text
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: theme.Fields.spacing.vertical) {
            HStack(alignment: .center, spacing: theme.Fields.spacing.horizontal) {
                SwiftUI.Text(label)
                    .foregroundColor(foregroundColor)
                    .font(theme.Fonts.body)
                    .accessibilityHidden(true)

                Spacer()

                if actualDate == nil {
                    HStack(spacing: 0) {
                        Button(.field_date_label.localized()) {
                            updateDate(selectedDate)
                        }
                        .buttonStyle(.link)
                        .frame(maxWidth: nil)

                        ImageButton(.open) {
                            updateDate(selectedDate)
                        }
                        .tintColor(tintColor)
                        .padding([.top, .bottom], theme.Fields.style.padding)
                        .accessibilityHidden(true)
                    }
                    .accessibilityAddTraits(.isButton)
                    .accessibilityElement(children: .combine)
                } else {
                    SwiftUI.DatePicker(
                        "",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .fixedSize()
                    .tint(theme.Colors.Background.interactive)
                    .focused($isFocused)
                    .onChange(of: selectedDate) { date in
                        updateDate(date)
                    }
                    .onChange(of: isFocused) { isFocused in
                        if !isFocused {
                            validator.validate()
                        }
                    }

                    ImageButton(.clear) {
                        actualDate = nil
                        text = ""
                        validator.validate()
                    }
                    .tintColor(tintColor)
                    .padding([.top, .bottom], theme.Fields.style.padding)
                }
            }

            if let errorMessage = errorMessage {
                SwiftUI.Text(errorMessage)
                    .font(theme.Fonts.subheadline)
                    .foregroundColor(borderColor)
                .transition(options.contentTransition)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel)
        .background(backgroundColor)
        .animation(options.contentAnimation, value: validator.state)

    }

    private var tintColor: Color {
        if actualDate == nil {
            return theme.Colors.Background.interactive
        }

        return borderColor
    }

    private var backgroundColor: Color {
        isEnabled ? .clear : Color(
            light: Color(uiColor: .systemGray6),
            dark: .clear
        )
    }

    private var foregroundColor: Color {
        switch validator.state {
        case .normal:
            return theme.Colors.Foreground.secondary
        case .error:
            return theme.Colors.Foreground.error
        }
    }

    private var borderColor: Color {
        switch validator.state {
        case .normal:
            return theme.Colors.Border.primary
        case .error:
            return theme.Colors.Border.error
        }
    }

    private func updateDate(_ date: Date) {
        actualDate = date
        text = formatter.string(from: date)
        validator.validate()
    }

    private var errorMessage: String? {
        if case .error(let message) = validator.state,
            let message = message {
            return String(format: message, label)
        }
        return nil
    }

    private var accessibilityLabel: Text {
        if let errorMessage = errorMessage {
            return Text(errorMessage)
        }

        return Text(label)
    }
}
