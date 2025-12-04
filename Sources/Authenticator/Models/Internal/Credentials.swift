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
    
    /// Tracks the currently selected auth factor during sign-in.
    /// Used to detect when user changes their auth factor selection after already selecting one.
    /// When non-nil, subsequent factor selections require restarting the sign-in flow.
    @Published var selectedAuthFactor: AuthFactor?
}
