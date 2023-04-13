//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

extension View {
    func messageBanner(_ message: Binding<AuthenticatorMessage?>) -> some View {
        self.modifier(AuthenticatorMessageModifier(message: message))
    }
}

private struct AuthenticatorMessageModifier: ViewModifier {
    @Binding var message: AuthenticatorMessage?

    @State private var dismissTimer: Timer? {
        willSet {
            dismissTimer?.invalidate()
        }
    }

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: .constant(message != nil)) {
                if let message = message {
                    VStack {
                        Spacer()
                        AuthenticatorMessageView(message: message, action: dismissErrorView)
                            .background(Color.clear)
                            .onAppear {
                                dismissTimer = Timer.scheduledTimer(
                                    withTimeInterval: 3,
                                    repeats: false
                                ) { _ in
                                    dismissErrorView()
                                }
                            }
                    }
                    .background(ClearBackgroundView()
                        .onTapGesture {
                            dismissErrorView()
                        }
                    )
                }
            }
    }

    private func dismissErrorView() {
        dismissTimer = nil
        message = nil
    }
}

private struct AuthenticatorMessageView: View {
    @Environment(\.authenticatorTheme) private var theme
    let message: AuthenticatorMessage
    let action: () -> ()

    var body: some View {
        HStack {
            Text(message.content)
                .font(theme.Fonts.callout)
            Spacer()
            ImageButton(.close) {
                action()
            }
            .tintColor(foregroundColor)
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(foregroundColor)
        .padding(theme.Banners.padding/2)
        .background(backgroundColor)
        .cornerRadius(theme.Banners.cornerRadius)
        .padding(theme.Banners.padding/2)
    }

    private var foregroundColor: Color {
        switch message.style {
        case .error:
            return theme.Colors.Foreground.error
        case .info:
            return theme.Colors.Foreground.info
        default:
            return theme.Colors.Foreground.primary
        }
    }

    private var backgroundColor: Color {
        switch message.style {
        case .error:
            return theme.Colors.Background.error
        case .info:
            return theme.Colors.Background.info
        default:
            return theme.Colors.Background.primary
        }
    }
}

struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return InnerView()
    }

    func updateUIView(_ uiView: UIView, context: Context) { }

    private class InnerView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            superview?.superview?.backgroundColor = .clear
        }
    }
}
