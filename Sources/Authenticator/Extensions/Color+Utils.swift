//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

extension Color {
    /// Creates a color using HSL (Hue, Saturation, and Lightness)
    init(hue: Int, saturation: Int, lightness: Int) {
        let hue = Double(hue) / 360.0
        let saturation = Double(saturation) / 100.0
        let lightness = Double(lightness) / 100.0

        let brightness = lightness + saturation * min(lightness, 1 - lightness)
        let newSaturation = brightness == 0 ? 0 : 2 * (1 - lightness / brightness)

        self.init(
            hue: hue,
            saturation: newSaturation,
            brightness: brightness
        )
    }

    /// Creates a color that suports Light and Dark mode
    init(light: Color, dark: Color) {
    #if os(iOS)
        self.init(
            uiColor: .init {
                if $0.userInterfaceStyle == .dark {
                    return UIColor(dark)
                } else {
                    return UIColor(light)
                }
            }
        )
    #elseif os(macOS)
        self.init(
            nsColor: .init(name: nil) {
                if $0.name == .darkAqua {
                    return NSColor(dark)
                } else {
                    return NSColor(light)
                }
            }
        )
    #endif
    }
}
