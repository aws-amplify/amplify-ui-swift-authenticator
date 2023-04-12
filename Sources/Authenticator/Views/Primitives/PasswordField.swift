//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

struct PasswordField: View {
    @Environment(\.authenticatorTheme) var theme
    @ObservedObject private var validator: Validator
    @Binding private var text: String
    @FocusState private var focusedField: FieldType?
    @State private var isShowingPassword: Bool = false
    private let label: String?
    private let placeholder: String

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
                createInput()
                    .disableAutocorrection(true)
                    .onChange(of: text) { text in
                        if validator.state != .normal || !text.isEmpty {
                            validator.validate()
                        }
                    }
                    .onChange(of: focusedField) { focused in
                        if focused == nil {
                            validator.validate()
                        }
                    }
    #if os(iOS)
                    .autocapitalization(.none)
                    .frame(height: 25)
                    .padding([.top, .bottom, .leading], theme.Fields.style.padding)
    #endif
                if focusedField != nil, !text.isEmpty {
                    ImageButton(showPasswordImage) {
                        isShowingPassword.toggle()
                        focusedField = isShowingPassword ? .plain : .secure
                    }
                    .tintColor(showPasswordButtonColor)
                    .padding([.top, .bottom, .trailing], theme.Fields.style.padding)
                }
            }
            .animation(.linear(duration: 0.1), value: isShowingPassword)
        }
    }

    @ViewBuilder private func createInput() -> some View {
        if isShowingPassword {
            SwiftUI.TextField(placeholder, text: $text)
                .focused($focusedField, equals: .plain)
        } else {
            SwiftUI.SecureField(placeholder, text: $text)
                .focused($focusedField, equals: .secure)
        }
    }

    private var isFocused: Bool {
        return focusedField != nil
    }

    private var showPasswordButtonColor: Color {
        switch validator.state {
        case .normal:
            return theme.Colors.Border.interactive
        case .error:
            return theme.Colors.Border.error
        }
    }

    private var showPasswordImage: ImageButton.Image {
        return isShowingPassword ? .showPassword : .hidePassword
    }

    private enum FieldType: Hashable {
        case plain
        case secure
    }
}
