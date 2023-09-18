//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

/// Represents a theme that is used to style the ``Authenticator``
public class AuthenticatorTheme: ObservableObject {
    /// Theming options for specific components
    public var components = Components()
    
    /// Defines the default fonts used by all components
    public var fonts = Fonts()
    
    /// Defines the default colors used by all components
    public var colors = Colors()
    
    /// Creates a new ``AuthenticatorTheme``
    public init() {}
}

extension AuthenticatorTheme {
    public struct Components {
        /// Theming options for the ``Authenticator`` component
        public var authenticator = Authenticator()
        
        /// Theming options for buttons
        public var button = Button()
        
        /// Theming options for input fields
        public var field = Field()
        
        /// Theming options for alerts
        public var alert = Alert()
    }
    
    public struct Fonts {
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

    public struct Colors {
        /// The colors used for foreground elements
        public var foreground: Color = SwiftUI.Color.AmplifyUI.Font
        
        /// The colors used for backgrounds elements
        public var background: Color = SwiftUI.Color.AmplifyUI.Background
        
        /// The colors used for borders
        public var border: Color = SwiftUI.Color.AmplifyUI.Border
    }
    
    public struct Spacing {
        public var horizontal: CGFloat
        public var vertical: CGFloat
    }
    
    /// Represents the padding that a component applies
    public struct Padding: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
        public var top: CGFloat
        public var bottom: CGFloat
        public var trailing: CGFloat
        public var leading: CGFloat
        
        /// Creates a Padding with specific values for each of the given edges
        public init(
            top: CGFloat,
            bottom: CGFloat,
            trailing: CGFloat,
            leading: CGFloat
        ) {
            self.top = top
            self.bottom = bottom
            self.trailing = trailing
            self.leading = leading
        }
        
        /// Creates a Padding that has the same given value for all edges
        public init(floatLiteral value: Double) {
            self.top = value
            self.bottom = value
            self.trailing = value
            self.leading = value
        }
        
        /// Creates a Padding that has the same given value for all edges
        public init(integerLiteral value: Int) {
            let all = CGFloat(integerLiteral: value)
            self.top = all
            self.bottom = all
            self.trailing = all
            self.leading = all
        }

        public static func /(lhs: Padding, rhs: Int) -> Padding {
            let divider = CGFloat(rhs)
            return Padding(
                top: lhs.top/divider,
                bottom: lhs.bottom/divider,
                trailing: lhs.trailing/divider,
                leading: lhs.leading/divider
            )
        }
    }
}

extension AuthenticatorTheme.Colors {
    /// Represents a group of colors
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
}

extension AuthenticatorTheme.Components {
    public struct Authenticator {
        init() {}
        public var spacing: AuthenticatorTheme.Spacing = .init(
            horizontal: 0,
            vertical: Platform.isMacOS ? 15 : 20
        )
        public var padding: AuthenticatorTheme.Padding = 20
        public var cornerRadius: CGFloat = 0
        public var borderWidth: CGFloat = 1
        public var backgroundColor: SwiftUI.Color = .clear
        public var qrCodeSize: CGFloat = 200
    }

    public struct Button {
        public var primary = Variation(
            font: Platform.isMacOS ? .title3.bold() : .body.bold(),
            cornerRadius: 5,
            padding: 13
        )
        public var link = Variation(
            font: Platform.isMacOS ? .body.weight(.semibold) : .subheadline.weight(.semibold),
            cornerRadius: 0,
            padding: 10
        )
        public var capsule = Variation(
            font: Platform.isMacOS ? .body.weight(.regular) : .subheadline.weight(.regular),
            cornerRadius: .infinity,
            padding: .init(top: 10, bottom: 10, trailing: 30, leading: 30)
        )
    }

    public struct Field {
        init() {}
        public var spacing: AuthenticatorTheme.Spacing = .init(
            horizontal: Platform.isMacOS ? 5 : 0,
            vertical: 5
        )
        public var padding: AuthenticatorTheme.Padding = 10
        public var cornerRadius: CGFloat = 5
        public var borderWidth: CGFloat = 1
        public var backgroundColor: SwiftUI.Color = Platform.isMacOS ? .AmplifyUI.Background.primary : .clear
    }
    
    public struct Alert {
        public var cornerRadius: CGFloat = 10
        public var padding: AuthenticatorTheme.Padding = 30
    }
}

extension AuthenticatorTheme.Components.Button {
    public struct Variation {
        public var font: SwiftUI.Font
        public var cornerRadius: CGFloat
        public var padding: AuthenticatorTheme.Padding?

        public init(
            font: SwiftUI.Font,
            cornerRadius: CGFloat,
            padding: AuthenticatorTheme.Padding? = nil
        ) {
            self.font = font
            self.cornerRadius = cornerRadius
            self.padding = padding
        }
    }
}
