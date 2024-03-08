//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

/// This field allows the user to enter a phone number
/// It consists of two fields: one for the dialing code and one for the actual phone number
/// and updates the associated Binding with the concatenation of both.
/// It also applies Amplify UI's theming
struct PhoneNumberField: View {
    @Environment(\.authenticatorTheme) var theme
    @ObservedObject private var validator: Validator
    @Binding private var text: String
    @FocusState private var isFocused: Bool
    @FocusState private var focusedField: FieldType?
    @State private var callingCode: String = RegionUtils.shared.currentCallingCode
    @State private var phoneNumber: String = ""

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
            isFocused: focusedField != nil
        ) {
            HStack(spacing: 0) {
                CallingCodeField(callingCode: $callingCode)
                    .foregroundColor(foregroundColor)
                    .focused($focusedField, equals: .callingCode)
                    .onChange(of: callingCode) { code in
                        if !phoneNumber.isEmpty {
                            text = "\(code)\(phoneNumber)"
                        }
                    }

                Divider()
                    .frame(width: 1)
                    .overlay(theme.colors.border.primary)

                SwiftUI.TextField(placeholder, text: $phoneNumber)
                    .disableAutocorrection(true)
                    .focused($focusedField, equals: .phoneNumber)
                    .onChange(of: phoneNumber) { newValue in
                        // Only allow characters used for representing phone numbers, i.e. numbers, spaces, parentheses and hyphens.
                        let allowedCharacters = newValue.filter("0123456789-() ".contains)
                        guard phoneNumber == allowedCharacters else {
                            phoneNumber = allowedCharacters
                            return
                        }

                        if phoneNumber.isEmpty {
                            // If the phone number is empty, we consider this to be an empty input regardless of the calling code, as that one is automatically populated
                            self.text = ""
                        } else {
                            // Only numbers are allowed by the service, so remove other characters in the internally tracked full phone number
                            let onlyNumbers = phoneNumber.filter("0123456789".contains)
                            self.text = "\(callingCode)\(onlyNumbers)"
                        }

                        if validator.state != .normal || !phoneNumber.isEmpty {
                            validator.validate()
                        }
                    }
                    .onChange(of: focusedField) { focusedField in
                        if focusedField == nil {
                            validator.validate()
                        }
                    }
                    .accessibilityLabel(Text(
                        "authenticator.field.phoneNumber.label".localized()
                    ))
                    .textFieldStyle(.plain)
                    .frame(height: Platform.isMacOS ? 20 : 25)
                    .padding([.top, .bottom, .leading], theme.components.field.padding)
                #if os(iOS)
                    .autocapitalization(.none)
                    .keyboardType(.numberPad)
                #endif

                if shouldDisplayClearButton {
                    ImageButton(.clear) {
                        phoneNumber = ""
                    }
                    .tintColor(borderColor)
                    .padding([.top, .bottom, .trailing], theme.components.field.padding)
                }
            }
            .focused($isFocused)
            .onChange(of: isFocused) { isFocused in
                if isFocused && !Platform.isMacOS {
                    focusedField = .phoneNumber
                }
            }
        }
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
            return theme.colors.border.interactive
        case .error:
            return theme.colors.border.error
        }
    }

    private var shouldDisplayClearButton: Bool {
        // Show the clear button when there's text and
        // the field is focused on non-macOS platforms
        return !text.isEmpty && (Platform.isMacOS || focusedField != nil)
    }

    private enum FieldType: Hashable {
        case callingCode
        case phoneNumber
    }
}

/// This allows the user to select a dialing code from a list of all available ones,
/// showing a localized name of the region associated with each code and its flag
struct CallingCodeField: View {
    @Environment(\.authenticatorTheme) var theme
    @State private var searchRegion: String = ""
    @State private var isShowingList = false
    @FocusState private var isFocused: Bool
    @Binding var callingCode: String
    private let defaultCallingCode = RegionUtils.shared.currentCallingCode
    private let maxCallingCodeLength = 4

    var body: some View {
        SwiftUI.Button(
            action: {
                isShowingList = true
            },
            label: {
                SwiftUI.Text(callingCode)
                    .textFieldStyle(.plain)
                    .frame(width: 55, height: 35)
            }
        )
        .buttonStyle(.borderless)
        .sheet(isPresented: $isShowingList) {
            if #available(iOS 16.0, macOS 13.0, *) {
                allRegionsContent
                    .presentationDetents([.medium, .large])
            } else {
                allRegionsContent
            }
        }
        .accessibilityLabel(Text(
            "authenticator.field.diallingCode.label".localized()
        ))
        .frame(width: 55)
    }

    private var allRegionsContent: some View {
    #if os(iOS)
        NavigationView {
            regionList
        }
        .searchable(
            text: $searchRegion,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "authenticator.countryCodes.search".localized()
        )
        .keyboardType(.default)
    #elseif os(macOS)
        VStack {
            SwiftUI.TextField("authenticator.countryCodes.search".localized(), text: $searchRegion)
                .padding([.leading, .top, .trailing])
                .textFieldStyle(.plain)
            Divider()
            regionList
        }
        .frame(width: 400, height: 300)
    #endif
    }

    private var regionList: some View {
        List {
            ForEach(regions, id: \.self) { region in
                SwiftUI.Button(
                    action: {
                        callingCode = region.callingCode
                        isShowingList = false
                    },
                    label: {
                        HStack {
                            Text("\(region.flag) \(region.name)")
                            Spacer()
                            Text("\(region.callingCode)")
                        }
                    }
                )
                .buttonStyle(.borderless)
                .accessibilityLabel(Text("\(region.name), \(region.callingCode)"))
                .accessibilityRemoveTraits(.isButton)
            }
        }
        .foregroundColor(theme.colors.foreground.primary)
        .listStyle(.plain)
    }

    private var regions: [Region] {
        let allRegions = RegionUtils.shared.allRegions
        guard !searchRegion.isEmpty else {
            return allRegions
        }

        return allRegions.filter {
            $0.name.lowercased().contains(searchRegion.lowercased())
            || $0.callingCode.lowercased().contains(searchRegion.lowercased())
        }
    }
}
