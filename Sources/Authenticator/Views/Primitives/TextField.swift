//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

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

                #if os(iOS)
                    .autocapitalization(.none)
                    .frame(height: 25)
                    .padding([.top, .bottom, .leading], theme.Fields.style.padding)
                #endif

                if isFocused, !text.isEmpty {
                    ImageButton(.clear) {
                        text = ""
                    }
                    .tintColor(clearButtonColor)
                    .padding([.top, .bottom, .trailing], theme.Fields.style.padding)
                }
            }
        }
    }

    private var clearButtonColor: Color {
        switch validator.state {
        case .normal:
            return theme.Colors.Border.interactive
        case .error:
            return theme.Colors.Border.error
        }
    }
}
