//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI
import UIKit

public class AuthenticatorTheme: ObservableObject {
    public struct Spacing {
        public var horizontal: CGFloat
        public var vertical: CGFloat
    }

    public struct Style {
        public var cornerRadius: CGFloat
        public var padding: CGFloat
        public var borderWidth: CGFloat
        public var backgroundColor: Color
    }

    public struct Font {
        init() {}
        public var largeTitle: SwiftUI.Font = .largeTitle
        public var title: SwiftUI.Font = .title
        public var title2: SwiftUI.Font = .title2
        public var title3: SwiftUI.Font = .title3
        public var headline: SwiftUI.Font = .headline
        public var subheadline: SwiftUI.Font = .subheadline
        public var body: SwiftUI.Font = .body
        public var callout: SwiftUI.Font = .callout
        public var caption: SwiftUI.Font = .caption
        public var caption2: SwiftUI.Font = .caption2
        public var footnote: SwiftUI.Font = .footnote
    }

    public struct Authenticator {
        init() {}
        public var spacing = Spacing (
            horizontal: 5,
            vertical: 20
        )
        public var style = Style(
            cornerRadius: 0,
            padding: 20,
            borderWidth: 1,
            backgroundColor: .clear
        )
        public var loadingBlur: CGFloat = 2
    }

    public struct Button {
        init() {}
        public struct Size {
            public var font: SwiftUI.Font
            public var cornerRadius: CGFloat
            public var padding: CGFloat?

            public init(
                font: SwiftUI.Font,
                cornerRadius: CGFloat,
                padding: CGFloat? = nil
            ) {
                self.font = font
                self.cornerRadius = cornerRadius
                self.padding = padding
            }
        }

        public var primary = Size(
            font: .body.bold(),
            cornerRadius: 5,
            padding: 13
        )
        public var link = Size(
            font: .system(size: 15, weight: .semibold),
            cornerRadius: 0,
            padding: 10
        )
    }

    public struct Field {
        init() {}
        public var spacing = Spacing(
            horizontal: 0,
            vertical: 5
        )
        public var style = Style(
            cornerRadius: 5,
            padding: 10,
            borderWidth: 1,
            backgroundColor: .clear
        )
    }

    public struct Banner {
        init() {}
        public var cornerRadius: CGFloat = 10
        public var padding: CGFloat = 30
    }

    public struct Colors {
        init() {}
        public struct Color {

            public var primary: SwiftUI.Color
            public var secondary: SwiftUI.Color
            public var tertiary: SwiftUI.Color
            public var disabled: SwiftUI.Color
            public var inverse: SwiftUI.Color
            public var interactive: SwiftUI.Color
            public var info: SwiftUI.Color
            public var warning: SwiftUI.Color
            public var error: SwiftUI.Color
            public var success: SwiftUI.Color

            public init(
                primary: SwiftUI.Color,
                secondary: SwiftUI.Color,
                tertiary: SwiftUI.Color,
                disabled: SwiftUI.Color,
                inverse: SwiftUI.Color,
                interactive: SwiftUI.Color,
                info: SwiftUI.Color,
                warning: SwiftUI.Color,
                error: SwiftUI.Color,
                success: SwiftUI.Color
            ) {
                self.primary = primary
                self.secondary = secondary
                self.tertiary = tertiary
                self.disabled = disabled
                self.inverse = inverse
                self.interactive = interactive
                self.info = info
                self.warning = warning
                self.error = error
                self.success = success
            }
        }

        public var Foreground = SwiftUI.Color.AmplifyUI.Font
        public var Background = SwiftUI.Color.AmplifyUI.Background
        public var Border = SwiftUI.Color.AmplifyUI.Border
    }

    public var Authenticator = Authenticator()
    public var Buttons = Button()
    public var Fonts = Font()
    public var Colors = Colors()
    public var Banners = Banner()
    public var Fields = Field()

    public init() {}
}
