//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

protocol KeyboardIterableFields: AuthenticatorLogging {
    associatedtype Field: Hashable
    var focusedField: FocusState<Field?> {set get}

    func focusPreviousField()

    func focusNextField()

    var hasPreviousField: Bool { get }

    var hasNextField: Bool { get }
}

extension KeyboardIterableFields where Field: RawRepresentable<Int>, Field: CaseIterable {
    private var currentIndex: Int? {
        return focusedField.wrappedValue?.rawValue
    }

    func focusPreviousField() {
        guard let currentIndex = currentIndex else { return }
        focusedField.wrappedValue = .init(rawValue: currentIndex - 1)
    }

    func focusNextField() {
        guard let currentIndex = currentIndex else { return }
        focusedField.wrappedValue = .init(rawValue: currentIndex + 1)
    }

    var hasPreviousField: Bool {
        guard let currentIndex = currentIndex else { return false }
        return currentIndex - 1 >= 0
    }

    var hasNextField: Bool {
        guard let currentIndex = currentIndex else { return false }
        return currentIndex + 1 < Field.allCases.count
    }
}

extension View {
    func keyboardIterableToolbar<F: KeyboardIterableFields>(fields: F) -> some View {
        self.modifier(KeyboardIterableToolbar(fields: fields))
    }
}

private struct KeyboardIterableToolbar<V>: ViewModifier where V: KeyboardIterableFields {
    let fields: V

    func body(content: Content) -> some View {
        content
            .toolbar {
                SwiftUI.ToolbarItem(placement: .keyboard) {
                    SwiftUI.Button(action: fields.focusPreviousField) {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(!fields.hasPreviousField)
                }
                SwiftUI.ToolbarItem(placement: .keyboard) {
                    SwiftUI.Button(action: fields.focusNextField) {
                        Image(systemName: "chevron.down")
                    }
                    .disabled(!fields.hasNextField)
                }
                SwiftUI.ToolbarItem(placement: .keyboard) {
                    Spacer()
                }
                SwiftUI.ToolbarItem(placement: .keyboard) {
                    SwiftUI.Button("authenticator.keyboardToolbar.Done".localized()) {
                        fields.focusedField.wrappedValue = nil
                    }
                }
            }
    }
}
