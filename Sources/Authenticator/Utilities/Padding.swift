//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

extension View {
    func padding(_ padding: AuthenticatorTheme.Padding?) -> some View {
        modifier(PaddingModifier(padding: padding))
    }
    
    func padding(_ edges: [Edge], _ padding: AuthenticatorTheme.Padding?) -> some View {
        modifier(PaddingWithEdgesModifier(edges: edges, padding: padding))
    }
    
    @ViewBuilder fileprivate func padding(_ edges: Edge.Set, _ padding: CGFloat?, if condition: Bool) -> some View {
        if condition {
            self.padding(edges, padding)
        } else {
            self
        }
    }
}

private struct PaddingModifier: ViewModifier {
    var padding: AuthenticatorTheme.Padding?

    func body(content: Content) -> some View {
        content
            .padding([.top], padding?.top)
            .padding([.bottom], padding?.bottom)
            .padding([.leading], padding?.leading)
            .padding([.trailing], padding?.trailing)
    }
}

private struct PaddingWithEdgesModifier: ViewModifier {
    var edges: [Edge]
    var padding: AuthenticatorTheme.Padding?

    func body(content: Content) -> some View {
        content
            .padding([.top], padding?.top, if: edges.contains(.top))
            .padding([.bottom], padding?.bottom, if: edges.contains(.bottom))
            .padding([.leading], padding?.leading, if: edges.contains(.leading))
            .padding([.trailing], padding?.trailing, if: edges.contains(.trailing))
    }
}
