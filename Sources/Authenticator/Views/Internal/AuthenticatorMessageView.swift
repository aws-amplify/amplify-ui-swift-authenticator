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
    @Environment(\.authenticatorOptions) var options
    @Binding var message: AuthenticatorMessage?

    @State private var dismissTimer: Timer? {
        willSet {
            dismissTimer?.invalidate()
        }
    }

    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .fullScreenCover(isPresented: .constant(message != nil)) {
                messageContent
            }
        #elseif os(macOS)
        ZStack {
            content
            messageContent
        }
        #endif
    }

    private func dismissErrorView() {
        dismissTimer = nil
        message = nil
    }

    @ViewBuilder private var messageContent: some View {
        VStack {
            if let message = message {
                Spacer()
                AuthenticatorMessageView(
                    message: message,
                    action: dismissErrorView
                )
                .onAppear {
                    dismissTimer = Timer.scheduledTimer(
                        withTimeInterval: 5,
                        repeats: false
                    ) { _ in
                        dismissErrorView()
                    }
                }
            #if os(macOS)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            #endif
            }
        }
    #if os(iOS)
        .background(ClearBackgroundView()
            .onTapGesture {
                dismissErrorView()
            }
        )
    #elseif os(macOS)
        .animation(options.contentAnimation, value: self.message != nil)
    #endif
    }
}

private struct AuthenticatorMessageView: View {
    @Environment(\.authenticatorTheme) private var theme
    let message: AuthenticatorMessage
    let action: () -> ()

    var body: some View {
        HStack {
            Text(message.content)
                .font(theme.fonts.callout)
            Spacer()
            ImageButton(.close) {
                action()
            }
            .tintColor(foregroundColor)
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(foregroundColor)
        .padding(theme.components.alert.padding/2)
        .background(backgroundColor)
        .cornerRadius(theme.components.alert.cornerRadius)
        .padding(theme.components.alert.padding/2)
    }

    private var foregroundColor: Color {
        switch message.style {
        case .error:
            return theme.colors.foreground.error
        case .info:
            return theme.colors.foreground.info
        default:
            return theme.colors.foreground.primary
        }
    }

    private var backgroundColor: Color {
        switch message.style {
        case .error:
            return theme.colors.background.error
        case .info:
            return theme.colors.background.info
        default:
            return theme.colors.background.primary
        }
    }
}

#if os(iOS)
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
#endif
