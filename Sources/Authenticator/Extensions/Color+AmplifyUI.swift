//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

extension Color {
    enum AmplifyUI {
        static var neutral10 = Color(hue: 210, saturation: 5, lightness: 98)
        static var neutral20 = Color(hue: 210, saturation: 5, lightness: 94)
        static var neutral40 = Color(hue: 210, saturation: 5, lightness: 87)
        static var neutral60 = Color(hue: 210, saturation: 10, lightness: 58)
        static var neutral80 = Color(hue: 210, saturation: 10, lightness: 40)
        static var neutral90 = Color(hue: 210, saturation: 25, lightness: 25)
        static var neutral100 = Color(hue: 210, saturation: 50, lightness: 10)

        static var red10 = Color(hue: 0, saturation: 75, lightness: 95)
        static var red20 = Color(hue: 0, saturation: 75, lightness: 85)
        static var red40 = Color(hue: 0, saturation: 75, lightness: 75)
        static var red60 = Color(hue: 0, saturation: 50, lightness: 50)
        static var red80 = Color(hue: 0, saturation: 95, lightness: 30)
        static var red90 = Color(hue: 0, saturation: 100, lightness: 20)
        static var red100 = Color(hue: 0, saturation: 100, lightness: 15)

        static var orange10 = Color(hue: 30, saturation: 75, lightness: 95)
        static var orange20 = Color(hue: 30, saturation: 75, lightness: 85)
        static var orange40 = Color(hue: 30, saturation: 75, lightness: 75)
        static var orange60 = Color(hue: 30, saturation: 50, lightness: 50)
        static var orange80 = Color(hue: 30, saturation: 95, lightness: 30)
        static var orange90 = Color(hue: 30, saturation: 100, lightness: 20)
        static var orange100 = Color(hue: 30, saturation: 100, lightness: 15)

        static var green10 = Color(hue: 130, saturation: 60, lightness: 95)
        static var green20 = Color(hue: 130, saturation: 60, lightness: 90)
        static var green40 = Color(hue: 130, saturation: 44, lightness: 63)
        static var green60 = Color(hue: 130, saturation: 43, lightness: 46)
        static var green80 = Color(hue: 130, saturation: 33, lightness: 37)
        static var green90 = Color(hue: 130, saturation: 27, lightness: 29)
        static var green100 = Color(hue: 130, saturation: 22, lightness: 23)

        static var teal10 = Color(hue: 190, saturation: 75, lightness: 95)
        static var teal20 = Color(hue: 190, saturation: 75, lightness: 85)
        static var teal40 = Color(hue: 190, saturation: 70, lightness: 70)
        static var teal60 = Color(hue: 190, saturation: 50, lightness: 50)
        static var teal80 = Color(hue: 190, saturation: 95, lightness: 30)
        static var teal90 = Color(hue: 190, saturation: 100, lightness: 20)
        static var teal100 = Color(hue: 190, saturation: 100, lightness: 15)

        static var blue10 = Color(hue: 220, saturation: 95, lightness: 95)
        static var blue20 = Color(hue: 220, saturation: 85, lightness: 85)
        static var blue40 = Color(hue: 220, saturation: 70, lightness: 70)
        static var blue60 = Color(hue: 220, saturation: 50, lightness: 50)
        static var blue80 = Color(hue: 220, saturation: 95, lightness: 30)
        static var blue90 = Color(hue: 220, saturation: 100, lightness: 20)
        static var blue100 = Color(hue: 220, saturation: 100, lightness: 15)

        static var purple10 = Color(hue: 300, saturation: 95, lightness: 95)
        static var purple20 = Color(hue: 300, saturation: 85, lightness: 85)
        static var purple40 = Color(hue: 300, saturation: 70, lightness: 70)
        static var purple60 = Color(hue: 300, saturation: 50, lightness: 50)
        static var purple80 = Color(hue: 300, saturation: 95, lightness: 30)
        static var purple90 = Color(hue: 300, saturation: 100, lightness: 20)
        static var purple100 = Color(hue: 300, saturation: 100, lightness: 15)

        static var black = Color(hue: 0, saturation: 0, lightness: 0)

        static var white = Color(hue: 0, saturation: 0, lightness: 100)

        static var transparent = Color.clear

        static let Font = AuthenticatorTheme.Colors.Color(
            primary: Color(light: .AmplifyUI.neutral100, dark: .AmplifyUI.white),
            secondary: Color(light: .AmplifyUI.neutral90, dark: .AmplifyUI.neutral10),
            tertiary: Color(light: .AmplifyUI.neutral80, dark: .AmplifyUI.neutral20),
            disabled: .AmplifyUI.neutral60,
            inverse: Color(light: .AmplifyUI.white, dark: .AmplifyUI.neutral100),
            interactive: Color(light: .AmplifyUI.teal80, dark: .AmplifyUI.teal40),
            info: Color(light: .AmplifyUI.blue90, dark: .AmplifyUI.blue40),
            warning: Color(light: .AmplifyUI.orange90, dark: .AmplifyUI.orange40),
            error: Color(light: .AmplifyUI.red90, dark: .AmplifyUI.red40),
            success: Color(light: .AmplifyUI.green90, dark: .AmplifyUI.green40)
        )

        static let Background = AuthenticatorTheme.Colors.Color(
            primary: Color(light: .AmplifyUI.white, dark: .AmplifyUI.black),
            secondary: .AmplifyUI.neutral10,
            tertiary: .AmplifyUI.neutral20,
            disabled: .AmplifyUI.neutral20,
            inverse: Color(light: .AmplifyUI.black, dark: .AmplifyUI.white),
            interactive: Color(light: .AmplifyUI.teal80, dark: .AmplifyUI.teal40),
            info: Color(light: .AmplifyUI.blue20, dark: .AmplifyUI.blue80),
            warning: Color(light: .AmplifyUI.orange20, dark: .AmplifyUI.orange80),
            error: Color(light: .AmplifyUI.red20, dark: .AmplifyUI.red80),
            success: Color(light: .AmplifyUI.green20, dark: .AmplifyUI.green80)
        )

        static let Border = AuthenticatorTheme.Colors.Color(
            primary: .AmplifyUI.neutral60,
            secondary: .AmplifyUI.neutral40,
            tertiary: .AmplifyUI.neutral20,
            disabled: .AmplifyUI.neutral20,
            inverse: .AmplifyUI.neutral40,
            interactive: Color(light: .AmplifyUI.teal80, dark: .AmplifyUI.teal40),
            info: .AmplifyUI.blue100,
            warning: Color(light: .AmplifyUI.orange80, dark: .AmplifyUI.orange40),
            error: Color(light: .AmplifyUI.red80, dark: .AmplifyUI.red40),
            success: Color(light: .AmplifyUI.green80, dark: .AmplifyUI.green40)
        )

        enum Brand {
            static var primary = Color.AmplifyUI.teal60
            static var secondary = Color.AmplifyUI.purple60
            static var tertiary = Color.AmplifyUI.purple60
        }
    }
}
