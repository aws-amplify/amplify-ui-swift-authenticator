//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

public extension Binding where Value == String {
    /// Returns a new Binding for Bool values
    func asBool() -> Binding<Bool> {
        return .init(
            get: {
                return Bool(wrappedValue) ?? false
            },
            set: { value in
                wrappedValue = String(value)
            }
        )
    }

    /// Returns a new Binding for Double values
    func asDouble() -> Binding<Double> {
        return .init(
            get: {
                return Double(wrappedValue) ?? 0
            },
            set: { value in
                wrappedValue = String(value)
            }
        )
    }

    /// Returns a new Binding for Int values
    func asInt() -> Binding<Int> {
        return .init(
            get: {
                return Int(wrappedValue) ?? 0
            },
            set: { value in
                wrappedValue = String(value)
            }
        )
    }
}
