//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

class AuthenticatorOptions: ObservableObject {
    @Published var hidesSignUpButton = false
    @Published var contentAnimation: Animation = .easeInOut(duration: 0.25)
    @Published var contentTransition: AnyTransition = .opacity
    @Published var signUpFields: [SignUpField] = []
    @Published var busyStyle = BusyStyle(content: ProgressView())

    struct BusyStyle {
        var blurRadius: CGFloat = 2
        var content: any View
    }
}
