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
            return "authenticator.field.email.label".localized()
        case .phoneNumber:
            return "authenticator.field.phoneNumber.label".localized()
        default:
            return ""
        }
    }
}
