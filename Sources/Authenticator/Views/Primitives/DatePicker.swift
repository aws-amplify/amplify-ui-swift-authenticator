//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

/// This field allows the user to select a date and parse it to a ISO-8601 format.
/// It allows to select a date by revealing a native `SwiftUI.DatePicker` when tapped.
/// It also applies Amplify UI theming
struct DatePicker: View {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.authenticatorOptions) private var options
    @Environment(\.authenticatorTheme) var theme
    @ObservedObject private var validator: Validator
    @State private var selectedDate: Date = .now
    @State private var actualDate: Date? = nil
    @State private var isShowingDatePicker = false
    @FocusState private var isFocused: Bool
    @Binding private var text: String
    private let label: String
    private let placeholder: String
    private var formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withFullDate
        return formatter
    }()

    init(_ label: String,
         text: Binding<String>,
         placeholder: String,
         validator: Validator? = nil) {
        self.label = label
        self._text = text
        self.placeholder = placeholder
        self.validator = validator ?? .init(
            using: FieldValidators.none
        )
        self.validator.value = text
        if let selectedDate = formatter.date(from: text.wrappedValue) {
            self._selectedDate = .init(wrappedValue: selectedDate)
            self._actualDate = .init(wrappedValue: selectedDate)
        }
    }

#if os(iOS)
    var body: some View {
        VStack(alignment: .trailing, spacing: theme.components.field.spacing.vertical) {
            AuthenticatorField(
                label,
                placeholder: placeholder,
                validator: validator,
                isFocused: isFocused
            ) {
                HStack(spacing: 0) {
                    createDisplayedDateText()

                    Spacer()

                    if !text.isEmpty {
                        ImageButton(.clear) {
                            actualDate = nil
                            text = ""
                            validator.validate()
                        }
                        .tintColor(clearButtonColor)
                        .padding([.top, .bottom, .trailing], theme.components.field.padding)
                    }

                    Divider()
                        .frame(width: 1)
                        .overlay(theme.colors.border.primary)

                    ImageButton(.calendar) {
                        withAnimation {
                            isShowingDatePicker.toggle()
                        }
                    }
                    .tintColor(tintColor)
                    .padding(theme.components.field.padding)
                    .frame(maxHeight: .infinity)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isShowingDatePicker.toggle()
                }
            }

            createDatePicker(style: .graphical)
                .frame(height: isShowingDatePicker ? nil : 0, alignment: .top)
                .disabled(!isShowingDatePicker)
                .clipped()
        }
    }
#elseif os(macOS)
    var body: some View {
        VStack(alignment: .trailing, spacing: theme.components.field.spacing.vertical) {
            AuthenticatorField(
                label,
                placeholder: placeholder,
                validator: validator,
                isFocused: isFocused
            ) {
                HStack(spacing: 0) {
                    if isShowingDatePicker {
                        createDatePicker(height: 20, style: .stepperField)
                    } else {
                        createDisplayedDateText()
                    }

                    Spacer()

                    if isShowingDatePicker {
                        ImageButton(.clear) {
                            actualDate = nil
                            text = ""
                            validator.validate()
                            isShowingDatePicker = false
                        }
                        .tintColor(clearButtonColor)
                        .padding([.top, .bottom, .trailing], theme.components.field.padding)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                guard !Platform.isMacOS || text.isEmpty else {
                    return
                }
                withAnimation {
                    isShowingDatePicker.toggle()
                }
            }
        }
    }
#endif

    @ViewBuilder private func createDatePicker<S: DatePickerStyle>(
        height: CGFloat? = nil,
        style: S
    ) -> some View {
        SwiftUI.DatePicker(
            "",
            selection: $selectedDate,
            displayedComponents: .date
        )
        .frame(height: height)
        .datePickerStyle(style)
        .tint(theme.colors.background.interactive)
        .onChange(of: selectedDate) { date in
            updateDate(date)
        }
        .environment(\.timeZone, timeZone)
        .padding([.top, .bottom], theme.components.field.padding)
    }

    @ViewBuilder private func createDisplayedDateText() -> some View {
        Text(displayedDate)
            .frame(height: Platform.isMacOS ? 20 : 25)
            .padding([.top, .bottom, .leading], theme.components.field.padding)
            .foregroundColor(text.isEmpty ? placeholderColor : theme.colors.foreground.primary)
            .accessibilityAddTraits(.isButton)
    }

    private var tintColor: Color {
        if isShowingDatePicker {
            return theme.colors.background.interactive
        }

        return borderColor
    }

    private var backgroundColor: Color {
        isEnabled ? .clear : Color(
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
            return theme.colors.border.primary
        case .error:
            return theme.colors.border.error
        }
    }

    private func updateDate(_ date: Date) {
        actualDate = date
        text = formatter.string(from: date)
        validator.validate()
    }

    private var displayedDate: String {
        guard let date = actualDate else {
            return placeholder
        }
        
        return date.formatted(Date.FormatStyle(
            date: .abbreviated,
            time: .omitted,
            timeZone: timeZone
        ))
    }

    private var placeholderColor: Color {
        Platform.isMacOS
        ? Color(red: 178/255, green: 178/255, blue: 178/255)
        : Color(red: 184/255, green: 184/255, blue: 187/255)
    }

    private var clearButtonColor: Color {
        switch validator.state {
        case .normal:
            return isFocused ?
            theme.colors.border.interactive : theme.colors.border.primary
        case .error:
            return theme.colors.border.error
        }
    }
    
    private var timeZone: TimeZone {
        TimeZone(secondsFromGMT: 0) ?? TimeZone.current
    }
}
