//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

/// This is a convenient way of having a Button display a single known image
struct ImageButton: View {
    private let image: Image
    private let action: () -> ()
    private var color: Color?

    init(
        _ image: Image,
        _ action: @escaping () ->()
    ) {
        self.image = image
        self.action = action
    }

    var body: some View {
        SwiftUI.Button(
            action: {
                action()
            },
            label: {
                SwiftUI.Image(systemName: image.rawValue)
            }
        )
        .foregroundColor(color)
        .accessibilityLabel(
            Text(accessibilityLabel)
        )
    }

    func tintColor(_ color: Color?) -> Self {
        var view = self
        view.color = color
        return view
    }

    private var accessibilityLabel: String {
        switch image {
        case .close:
            return .imageButton_close.localized()
        case .clear:
            return .imageButton_clear.localized()
        case .open:
            return .imageButton_open.localized()
        case .showPassword:
            return .imageButton_showPassword.localized()
        case .hidePassword:
            return .imageButton_hidePassword.localized()
        }
    }
}

extension ImageButton {
    enum Image: String {
        case close = "x.circle.fill"
        case clear = "xmark.circle.fill"
        case open = "chevron.down.circle"
        case showPassword = "eye.fill"
        case hidePassword = "eye.slash.fill"
    }
}
