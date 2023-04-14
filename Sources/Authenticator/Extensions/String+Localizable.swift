//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension String {
    /// Looks for a localized value using this value as the key.
    /// If no localization is found in the current app's bundle,
    /// it defaults to the one provided by Authenticator
    func localized(comment: String = "") -> String {
        let defaultValue = NSLocalizedString(self, bundle: .module, comment: "")
        return NSLocalizedString(
            self,
            bundle: .main,
            value: defaultValue,
            comment: ""
        )
    }

    func localized(using arguments: CVarArg...) -> String {
        return String(format: localized(), arguments)
    }
}
