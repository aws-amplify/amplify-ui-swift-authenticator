//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// The Authenticator component
public struct Authenticator<LoadingContent: View,
                            SignInContent: View,
                            ConfirmSignInWithNewPasswordContent: View,
                            ConfirmSignInWithMFACodeContent: View,
                            ConfirmSignInWithCustomChallengeContent: View,
                            SignUpContent: View,
                            ConfirmSignUpContent: View,
                            ResetPasswordContent: View,
                            ConfirmResetPasswordContent: View,
                            VerifyUserContent: View,
                            ConfirmVerifyUserContent: View,
                            SignedInContent: View,
                            ErrorContent: View,
                            Header: View,
                            Footer: View>: View {
    @Environment(\.authenticationService) var authenticationService
    @Environment(\.authenticatorState) var state
    @State private var currentStep: Step = .loading
    @State private var previousStep: Step = .loading
    private var initialStep: AuthenticatorInitialStep
    private var viewModifiers = ViewModifiers()
    private var contentStates: NSHashTable<AuthenticatorBaseState> = .weakObjects()
    private let loadingContent: LoadingContent
    private let signInContent: SignInContent
    private let confirmSignInContentWithMFACodeContent: ConfirmSignInWithMFACodeContent
    private let confirmSignInContentWithCustomChallengeContent: ConfirmSignInWithCustomChallengeContent
    private let confirmSignInContentWithNewPasswordContent: ConfirmSignInWithNewPasswordContent
    private let signUpContent: SignUpContent
    private let confirmSignUpContent: ConfirmSignUpContent
    private let resetPasswordContent: ResetPasswordContent
    private let confirmResetPasswordContent: ConfirmResetPasswordContent
    private let verifyUserContent: VerifyUserContent
    private let confirmVerifyUserContent: ConfirmVerifyUserContent
    private let headerContent: Header
    private let footerContent: Footer
    private let errorContentBuilder: (Error) -> ErrorContent
    private let signedInContentBuilder: (SignedInState) -> SignedInContent

    /// Creates an `Authenticator` component
    /// - Parameter initialStep: The initial step displayed to unauthorized users.
    /// Defaults to ``AuthenticatorInitialStep/signIn``
    /// - Parameter loadingContent: The content that is associated with the ``AuthenticatorStep/loading`` step.
    /// Defaults to a `SwiftUI.ProgressView`.
    /// - Parameter signInContent: The content associated with the ``AuthenticatorStep/signIn`` step.
    /// Defaults to a ``SignInView``.
    /// - Parameter confirmSignInWithMFACodeContent: The content associated with the ``AuthenticatorStep/confirmSignInWithCustomChallenge`` step.
    /// Defaults to a ``ConfirmSignInWithMFACodeView``.
    /// - Parameter confirmSignInWithCustomChallengeContent: The content associated with the ``AuthenticatorStep/confirmSignInWithMFACode`` step.
    /// Defaults to a ``ConfirmSignInWithCustomChallengeView``.
    /// - Parameter confirmSignInWithNewPasswordContent: The content associated with the ``AuthenticatorStep/confirmSignInWithNewPassword`` step.
    /// Defaults to a ``ConfirmSignInWithNewPasswordView``.
    /// - Parameter signUpContent: The content associated with the ``AuthenticatorStep/signUp`` step.
    /// Defaults to a ``SignUpView``.
    /// - Parameter confirmSignUpContent: The content associated with the ``AuthenticatorStep/confirmSignUp`` step.
    /// Defaults to a ``ConfirmSignUpView``.
    /// - Parameter resetPasswordContent: The content associated with the ``AuthenticatorStep/resetPassword`` step.
    /// Defaults to a ``ResetPasswordView``.
    /// - Parameter confirmResetPasswordContent: The content associated with the ``AuthenticatorStep/confirmResetPassword`` step.
    /// Defaults to a ``ConfirmResetPasswordView``.
    /// - Parameter verifyUserContent: The content associated with the ``AuthenticatorStep/verifyUser`` step.
    /// Defaults to a ``VerifyUserView``.
    /// - Parameter confirmVerifyUserContent: The content associated with the ``AuthenticatorStep/confirmVerifyUser`` step.
    /// Defaults to a ``ConfirmVerifyUserView``.
    /// - Parameter errorContent: The content associated with the ``AuthenticatorStep/error`` step.
    /// Defaults to a ``ErrorView``.
    /// - Parameter headerContent: A custom header content that is displayed on top of any other Authenticator content.
    /// Defaults to a `SwiftUI.EmptyView`.
    /// - Parameter footerContent: A custom footer content that is displayed below any other Authenticator content.
    /// Defaults to a `SwiftUI.EmptyView`.
    /// - Parameter content: The content associated with the ``AuthenticatorStep/signedIn`` step, i.e. once the user has successfully authenticated.
    public init(
        initialStep: AuthenticatorInitialStep = .signIn,
        @ViewBuilder loadingContent: () -> LoadingContent = {
            ProgressView()
        },
        @ViewBuilder signInContent: (SignInState) -> SignInContent = { state in
            SignInView(state: state)
        },
        @ViewBuilder confirmSignInWithMFACodeContent: (ConfirmSignInWithCodeState) -> ConfirmSignInWithMFACodeContent = { state in
            ConfirmSignInWithMFACodeView(state: state)
        },
        @ViewBuilder confirmSignInWithCustomChallengeContent: (ConfirmSignInWithCodeState) -> ConfirmSignInWithCustomChallengeContent = { state in
            ConfirmSignInWithCustomChallengeView(state: state)
        },
        @ViewBuilder confirmSignInWithNewPasswordContent: (ConfirmSignInWithNewPasswordState) -> ConfirmSignInWithNewPasswordContent = { state in
            ConfirmSignInWithNewPasswordView(state: state)
        },
        @ViewBuilder signUpContent: (SignUpState) -> SignUpContent = { state in
            SignUpView(state: state)
        },
        @ViewBuilder confirmSignUpContent: (ConfirmSignUpState) -> ConfirmSignUpContent = { state in
            ConfirmSignUpView(state: state)
        },
        @ViewBuilder resetPasswordContent: (ResetPasswordState) -> ResetPasswordContent = { state in
            ResetPasswordView(state: state)
        },
        @ViewBuilder confirmResetPasswordContent: (ConfirmResetPasswordState) -> ConfirmResetPasswordContent = { state in
            ConfirmResetPasswordView(state: state)
        },
        @ViewBuilder verifyUserContent: (VerifyUserState) -> VerifyUserContent = { state in
            VerifyUserView(state: state)
        },
        @ViewBuilder confirmVerifyUserContent: (ConfirmVerifyUserState) -> ConfirmVerifyUserContent = { state in
            ConfirmVerifyUserView(state: state)
        },
        @ViewBuilder errorContent: @escaping (Error) -> ErrorContent = { _ in
            ErrorView()
        },
        @ViewBuilder headerContent: () -> Header = { EmptyView() },
        @ViewBuilder footerContent: () -> Footer = { EmptyView() },
        @ViewBuilder content: @escaping (SignedInState) -> SignedInContent
    ) {
        self.initialStep = initialStep
        self.loadingContent = loadingContent()
        let credentials = Credentials()

        let signInState = SignInState(credentials: credentials)
        contentStates.add(signInState)
        self.signInContent = signInContent(signInState)

        let confirmSignInWithMFACodeState = ConfirmSignInWithCodeState(credentials: credentials)
        contentStates.add(confirmSignInWithMFACodeState)
        self.confirmSignInContentWithMFACodeContent = confirmSignInWithMFACodeContent(
            confirmSignInWithMFACodeState
        )

        let confirmSignInWithCustomChallengeState = ConfirmSignInWithCodeState(credentials: credentials)
        contentStates.add(confirmSignInWithMFACodeState)
        self.confirmSignInContentWithCustomChallengeContent = confirmSignInWithCustomChallengeContent(
            confirmSignInWithCustomChallengeState
        )

        let confirmSignInWithNewPasswordState = ConfirmSignInWithNewPasswordState(credentials: credentials)
        contentStates.add(confirmSignInWithNewPasswordState)
        self.confirmSignInContentWithNewPasswordContent = confirmSignInWithNewPasswordContent(
            confirmSignInWithNewPasswordState
        )

        let signUpState = SignUpState(credentials: credentials)
        contentStates.add(signUpState)
        self.signUpContent = signUpContent(signUpState)

        let confirmSignUpState = ConfirmSignUpState(credentials: credentials)
        contentStates.add(confirmSignUpState)
        self.confirmSignUpContent = confirmSignUpContent(confirmSignUpState)

        let resetPasswordState = ResetPasswordState(credentials: credentials)
        contentStates.add(resetPasswordState)
        self.resetPasswordContent = resetPasswordContent(resetPasswordState)

        let confirmResetPasswordState = ConfirmResetPasswordState(credentials: credentials)
        contentStates.add(confirmResetPasswordState)
        self.confirmResetPasswordContent = confirmResetPasswordContent(confirmResetPasswordState)

        let verifyUserState = VerifyUserState(credentials: credentials)
        contentStates.add(verifyUserState)
        self.verifyUserContent = verifyUserContent(verifyUserState)

        let confirmVerifyUserState = ConfirmVerifyUserState(credentials: credentials)
        contentStates.add(confirmVerifyUserState)
        self.confirmVerifyUserContent = confirmVerifyUserContent(confirmVerifyUserState)

        self.headerContent = headerContent()
        self.footerContent = footerContent()
        self.errorContentBuilder = errorContent
        self.signedInContentBuilder = content
    }

    public var body: some View {
        VStack {
            Group {
                if case .signedIn(let user) = currentStep {
                    let signedInState = SignedInState(
                        user: user,
                        authenticationService: authenticationService
                    )
                    signedInContentBuilder(signedInState)
                        .environmentObject(signedInState)
                } else {
                    headerContent
                    createView(for: currentStep)
                    footerContent
                }
            }
            .transition(contentTransition)
        }
        .animation(viewModifiers.contentAnimation, value: currentStep)
        .environment(\.authenticatorOptions.hidesSignUpButton, viewModifiers.hidesSignUpButton)
        .environment(\.authenticatorOptions.contentAnimation, viewModifiers.contentAnimation)
        .environment(\.authenticatorOptions.contentTransition, viewModifiers.contentTransition)
        .environment(\.authenticatorOptions.signUpFields, viewModifiers.signUpFields)
        .environment(\.authenticatorOptions.busyStyle, viewModifiers.busyStyle)
        .task {
            state.authenticationService = authenticationService
            setUpContentStates(contentStates)
            await state.reloadState(initialStep: initialStep)
        }
        .onChange(of: contentStates) { contentStates in
            setUpContentStates(contentStates)
        }
        .onChange(of: initialStep) { initialStep in
            Task {
                await state.reloadState(initialStep: initialStep)
            }
        }
        .onReceive(state.$step) {
            self.previousStep = self.currentStep
            self.currentStep = $0
        }
    }

    /// Hides the Sign Up Button that is displayed in the default ``SignInView``.
    /// - Parameter hidesSignUpButton: Whether to hide the Sign Up button. Defaults to true
    public func hidesSignUpButton(_ hidesSignUpButton: Bool = true) -> Self {
        var view = self
        view.viewModifiers.hidesSignUpButton = hidesSignUpButton
        return view
    }

    /// Sets the animation used to transition between steps.
    /// - Parameter animation: The animation that will be used to apply UI changes when the Authenticator's current step changes.
    public func contentAnimation(_ animation: Animation) -> Self {
        var view = self
        view.viewModifiers.contentAnimation = animation
        return view
    }

    /// Sets the transition used to transition between steps.
    /// - Parameter transition: The transition that will be used to apply UI changes when the Authenticator's current step changes.
    public func contentTransition(_ transition: AnyTransition) -> Self {
        var view = self
        view.viewModifiers.contentTransition = transition
        return view
    }

    /// Sets the Sign Up fields that will be displayed in the `.signUp` step.
    /// - Parameter signUpFields: An array of Sign Up fields that will be displayed when signing up. The order of the array is mantained when displaying the fields.
    public func signUpFields(_ signUpFields: [SignUpField]) -> Self {
        var view = self
        view.viewModifiers.signUpFields = signUpFields
        return view
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError) -> Self {
        for contentState in contentStates.allObjects {
            contentState.errorTransform = errorTransform
        }
        return self
    }

    /// Sets the style that is applied when an operation is in progress
    /// - Parameter blurRadius: The radial size that determines how diffuse the blur behind the content is.
    public func busyStyle(blurRadius: CGFloat) -> Self {
        var view = self
        view.viewModifiers.busyStyle.blurRadius = blurRadius
        return view
    }

    /// Sets the style that is applied when an operation is in progress
    /// - Parameter blurRadius: The radial size that determines how diffuse the blur behind the content is.
    ///  Defaults to `nil`, which keeps the existing value.
    /// - Parameter content: A closure that returns the content that is displayed while an operation is in progress
    public func busyStyle<Content: View>(blurRadius: CGFloat? = nil, content: () -> Content) -> Self {
        var view = self
        view.viewModifiers.busyStyle.content = content()
        if let blurRadius = blurRadius {
            view.viewModifiers.busyStyle.blurRadius = blurRadius
        }
        return view
    }

    /// Sets a custom theme
    /// - Parameter theme: A theme that will be applied to the Authenticator and all its views
    public func authenticatorTheme(_ theme: AuthenticatorTheme) -> some View {
        environment(\.authenticatorTheme, theme)
    }

    func authenticationService(_ authenticationService: AuthenticationService) -> some View {
        environment(\.authenticationService, authenticationService)
    }

    @ViewBuilder private func createView(for step: Step) -> some View {
        switch step {
        case .loading:
            loadingContent
        case .signIn:
            signInContent
        case .confirmSignInWithNewPassword:
            confirmSignInContentWithNewPasswordContent
        case .confirmSignInWithMFACode:
            confirmSignInContentWithMFACodeContent
        case .confirmSignInWithCustomChallenge:
            confirmSignInContentWithCustomChallengeContent
        case .resetPassword:
            resetPasswordContent
        case .confirmResetPassword:
            confirmResetPasswordContent
        case .signUp:
            signUpContent
        case .confirmSignUp:
            confirmSignUpContent
        case .verifyUser:
            verifyUserContent
        case .confirmVerifyUser:
            confirmVerifyUserContent
        case .error(let error):
            errorContentBuilder(error)
        case .signedIn(_):
            // Should never happen
            EmptyView()
        }
    }

    private var contentTransition: AnyTransition {
        if previousStep == .loading {
            return .opacity
        }

        return viewModifiers.contentTransition
    }

    private func setUpContentStates(_ contentStates: NSHashTable<AuthenticatorBaseState>) {
        for contentState in contentStates.allObjects {
            contentState.configure(with: state)
        }
    }
}

extension Authenticator {
    private struct ViewModifiers {
        var hidesSignUpButton = false
        var contentAnimation: Animation = .easeInOut(duration: 0.25)
        var contentTransition: AnyTransition = .opacity
        var signUpFields: [SignUpField] = []
        var busyStyle = AuthenticatorOptions.BusyStyle(content: ProgressView())
    }
}
