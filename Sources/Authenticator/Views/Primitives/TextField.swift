//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

/// This field allows the user to enter any text-based input
/// It applies Amplify UI theming
struct TextField: View {
    @Environment(\.authenticatorTheme) var theme
    @ObservedObject private var validator: Validator
    @Binding private var text: String
    @FocusState private var isFocused: Bool
    private let label: String?
    private let placeholder: String
    private var image: Image?

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
    }

    init(_ placeholder: String,
         text: Binding<String>,
         validator: Validator? = nil) {
        self.label = nil
        self._text = text
        self.placeholder = placeholder
        self.validator = validator ?? .init(
            using: FieldValidators.none
        )
        self.validator.value = text
    }

    var body: some View {
        AuthenticatorField(
            label,
            placeholder: placeholder,
            validator: validator,
            isFocused: isFocused
        ) {
            HStack {
                SwiftUI.TextField(placeholder, text: $text)
                    .disableAutocorrection(true)
                    .focused($isFocused)
                    .onChange(of: text) { text in
                        if validator.state != .normal || !text.isEmpty {
                            validator.validate()
                        }
                    }
                    .onChange(of: isFocused) { isFocused in
                        if !isFocused {
                            validator.validate()
                        }
                    }
                    .textFieldStyle(.plain)
                    .frame(height: Platform.isMacOS ? 20 : 25)
                    .padding([.top, .bottom, .leading], theme.components.field.padding)
                #if os(iOS)
                    .autocapitalization(.none)
                #endif

                if shouldDisplayClearButton {
                    ImageButton(.clear) {
                        text = ""
                    }
                    .tintColor(clearButtonColor)
                    .padding([.top, .bottom, .trailing], theme.components.field.padding)
                }
            }
        }
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

    private var shouldDisplayClearButton: Bool {
        // Show the clear button when there's text and
        // the field is focused on non-macOS platforms
        return !text.isEmpty && (Platform.isMacOS || isFocused)
    }
}
