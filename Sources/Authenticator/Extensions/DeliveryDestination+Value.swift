//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify

extension DeliveryDestination {
    var value: String? {
        switch self {
        case .email(let destination):
            return destination
        case .phone(let destination):
            return destination
        case .sms(let destination):
            return destination
        case .unknown(let destination):
            return destination
        }
    }
}
