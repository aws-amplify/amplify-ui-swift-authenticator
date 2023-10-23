//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

/// Default QRCodeContent for the ``ContinueSignInWithTOTPSetupView``. It displays the view's QR Code
public struct ContinueSignInWithTOTPCopyKeyView: View {

    @ObservedObject private var state: ContinueSignInWithTOTPSetupState

    public init(state: ContinueSignInWithTOTPSetupState) {
        self.state = state
    }

    public var body: some View {
        Button("authenticator.continueSignInWithTOTPSetup.button.copyKey".localized()) {
#if os(iOS)
            UIPasteboard.general.string = state.sharedSecret
#elseif os(macOS)
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(sharedSecret, forType: .string)
#endif
        }
        .buttonStyle(.capsule)
    }

}

extension ContinueSignInWithTOTPCopyKeyView: AuthenticatorLogging {}
