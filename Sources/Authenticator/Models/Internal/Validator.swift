//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

class Validator: ObservableObject {
    enum State: Equatable {
        case normal
        case error(message: String?)
    }

    @Published var state: State
    var value: Binding<String>

    private let validator: FieldValidator

    init(using validator: @escaping FieldValidator) {
        self.value = .constant("")
        self.state = .normal
        self.validator = validator
        if !self.value.wrappedValue.isEmpty {
            self.validate()
        }
    }

    @discardableResult
    func validate() -> Bool {
        if let error = validator(value.wrappedValue) {
            state = .error(message: error.description)
            return false
        }
        state = .normal
        return true
    }
}
