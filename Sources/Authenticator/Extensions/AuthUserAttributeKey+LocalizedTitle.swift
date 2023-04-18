//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify

extension AuthUserAttributeKey {
    var localizedTitle: String {
        switch self {
        case .email:
            return .field_email_label.localized()
        case .phoneNumber:
            return .field_phoneNumber_label.localized()
        default:
            return ""
        }
    }
}
