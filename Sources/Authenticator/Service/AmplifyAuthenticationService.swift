//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

typealias AmplifyAuthenticationService = AuthCategory

extension AuthenticationService where Self == AmplifyAuthenticationService {
    static var `default`: AuthenticationService {
        return Amplify.Auth
    }
}
