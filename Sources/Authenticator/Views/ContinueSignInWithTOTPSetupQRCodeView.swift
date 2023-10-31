//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

/// Default QRCodeContent for the ``ContinueSignInWithTOTPSetupView``. It displays the view's QR Code
public struct ContinueSignInWithTOTPSetupQRCodeView: View {

    @Environment(\.authenticatorTheme) private var theme
    @ObservedObject private var state: ContinueSignInWithTOTPSetupState

    public init(state: ContinueSignInWithTOTPSetupState) {
        self.state = state
    }

    public var body: some View {
        if let qrCodeImage = generateQRCode(qrCodeURIString: state.setupURI) {
            Image(decorative: qrCodeImage, scale: 1)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: theme.components.authenticator.qrCodeSize,
                       height: theme.components.authenticator.qrCodeSize)
        }
    }

    private func generateQRCode(qrCodeURIString: String?) -> CGImage? {
        guard let qrCodeURIString = qrCodeURIString else {
            return nil
        }

        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(qrCodeURIString.utf8)
        guard let outputImage = filter.outputImage else {
            log.error("Unable to create a CI Image for TOTP Setup QRCode")
            return nil
        }
        guard let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) else {
            log.error("Unable to create a CGImage from CIImage for TOTP Setup QRCode ")
            return nil
        }
        return cgImage
    }
}

extension ContinueSignInWithTOTPSetupQRCodeView: AuthenticatorLogging {}
