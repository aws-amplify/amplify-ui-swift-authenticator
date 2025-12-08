//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents the content being displayed when the ``Authenticator`` is in the ``AuthenticatorStep/signInSelectAuthFactor`` step.
public struct SignInSelectAuthFactorView<Header: View,
                                         Footer: View>: View {
    @Environment(\.authenticatorState) private var authenticatorState
    @Environment(\.authenticatorTheme) var theme
    @StateObject private var passwordValidator: Validator
    @ObservedObject private var state: SignInSelectAuthFactorState
    private let headerContent: Header
    private let footerContent: Footer

    /// Creates a `SignInSelectAuthFactorView`
    /// - Parameter state: The ``SignInSelectAuthFactorState`` that is observed by this view
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``SignInSelectAuthFactorHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  ``SignInSelectAuthFactorFooter``
    public init(
        state: SignInSelectAuthFactorState,
        @ViewBuilder headerContent: () -> Header = {
            SignInSelectAuthFactorHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            SignInSelectAuthFactorFooter()
        }
    ) {
        self._state = ObservedObject(wrappedValue: state)
        self.headerContent = headerContent()
        self.footerContent = footerContent()
        self._passwordValidator = StateObject(wrappedValue: Validator(
            using: FieldValidators.required
        ))
    }

    public var body: some View {
        AuthenticatorView(isBusy: state.isBusy) {
            headerContent
            
            TextField(
                "authenticator.field.username.label".localized(),
                text: .constant(state.username),
                placeholder: ""
            )
            .disabled(true)

            // Show password field if password is one of the available factors
            if state.availableAuthFactors.containsPassword {
                PasswordField(
                    "authenticator.field.password.label".localized(),
                    text: $state.password,
                    placeholder: "authenticator.field.password.placeholder".localized(),
                    validator: passwordValidator
                )
                .textContentType(.password)
            #if os(iOS)
                .textInputAutocapitalization(.never)
            #endif
                
                Button("authenticator.signInSelectAuthFactor.button.signInWithPassword".localized()) {
                    Task {
                        await signInWithPassword()
                    }
                }
                .buttonStyle(.primary)
            }
            
            // Show separator if password is available and there are other factors
            if state.availableAuthFactors.containsPassword &&
               state.availableAuthFactors.count > 1 {
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(theme.colors.border.primary)
                    Text("authenticator.signInSelectAuthFactor.separator.or".localized())
                        .font(theme.fonts.body)
                        .foregroundColor(theme.colors.border.primary)
                        .padding(.horizontal, 8)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(theme.colors.border.primary)
                }
                .padding(.vertical, 8)
            }
            
            // Show buttons for other auth factors
            ForEach(state.availableAuthFactors.nonPasswordFactors, id: \.self) { factor in
                Button(buttonTitle(for: factor)) {
                    Task {
                        await selectAuthFactor(factor)
                    }
                }
                .buttonStyle(.primary)
            }

            footerContent
        }
        .messageBanner($state.message)
        .onSubmit {
            Task {
                await signInWithPassword()
            }
        }
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError?) -> Self {
        state.errorTransform = errorTransform
        return self
    }

    private func signInWithPassword() async {
        guard passwordValidator.validate() else {
            log.verbose("Password validation failed")
            return
        }
        
        // Find the preferred password auth factor (prefers SRP over non-SRP)
        guard let passwordFactor = state.availableAuthFactors.preferredPasswordFactor else {
            log.verbose("Password auth factor not available")
            return
        }
        
        await selectAuthFactor(passwordFactor)
    }
    
    private func selectAuthFactor(_ factor: AuthFactor) async {
        state.selectedAuthFactor = factor
        try? await state.selectAuthFactor()
    }
    
    private func buttonTitle(for factor: AuthFactor) -> String {
        switch factor {
        case .password:
            return "authenticator.signInSelectAuthFactor.button.signInWithPassword".localized()
        case .emailOtp:
            return "authenticator.signInSelectAuthFactor.button.signInWithEmail".localized()
        case .smsOtp:
            return "authenticator.signInSelectAuthFactor.button.signInWithSMS".localized()
        case .webAuthn:
            return "authenticator.signInSelectAuthFactor.button.signInWithPasskey".localized()
        }
    }
}

extension SignInSelectAuthFactorView: AuthenticatorLogging {}

/// Default header for the ``SignInSelectAuthFactorView``. It displays the view's title
public struct SignInSelectAuthFactorHeader: View {
    public init() {}
    public var body: some View {
        DefaultHeader(
            title: "authenticator.signInSelectAuthFactor.title".localized()
        )
    }
}

/// Default footer for the ``SignInSelectAuthFactorView``. It displays the "Back to Sign In" button
public struct SignInSelectAuthFactorFooter: View {
    @Environment(\.authenticatorState) private var authenticatorState

    public init() {}
    public var body: some View {
        Button("authenticator.signInSelectAuthFactor.button.backToSignIn".localized()) {
            authenticatorState.move(to: .signIn)
        }
        .buttonStyle(.link)
    }
}
