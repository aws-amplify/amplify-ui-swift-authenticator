//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

class Credentials: ObservableObject {
    @Published var username: String = ""
    @Published var password: String?

    @Published var message: AuthenticatorMessage?
}
