//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import SwiftUI

/// Represents the content being displayed when the Authenticator is in the `.signUp` step.
public struct SignUpView<Header: View,
                         Footer: View>: View, KeyboardIterableFields {
    @Environment(\.authenticatorState) private var authenticatorState
    @Environment(\.authenticatorOptions) private var options
    @StateObject private var validators: Validators
    @ObservedObject private var state: SignUpState
    private let headerContent: Header
    private let footerContent: Footer
    private let overridenSignUpFields: [SignUpField]?

    var focusedField: FocusState<SignUpAttribute?> = FocusState()

    /// Creates a `SignUpView`
    /// - Parameter state: The ``SignUpState`` that is observed by this view
    /// - Parameter signUpFields: An array of Sign Up fields that will be displayed when signing up. The order of the array is mantained when displaying the fields. If empty or `nil`, the fields will be determined from Amplify's configuration. Defaults to `nil`
    /// - Parameter headerContent: The content displayed above the fields. Defaults to  ``SignUpHeader``
    /// - Parameter footerContent: The content displayed bellow the fields. Defaults to  ``SignUpFooter``
    public init(
        state: SignUpState,
        signUpFields: [SignUpField]? = nil,
        @ViewBuilder headerContent: () -> Header = {
            SignUpHeader()
        },
        @ViewBuilder footerContent: () -> Footer = {
            SignUpFooter()
        }
    ) {
        self.state = state
        self.focusedField.wrappedValue = nil
        self.headerContent = headerContent()
        self.footerContent = footerContent()
        self.overridenSignUpFields = signUpFields
        let validators = Validators(state: state)
        self._validators = StateObject(wrappedValue: validators)
    }

    public var body: some View {
        AuthenticatorView(isBusy: state.isBusy) {
            headerContent
            
            ForEach(state.fields, id: \.self) { field in
                SignUpInputField(
                    field: field,
                    validator: validators.validator(for: field.field)
                )
                .textInputAutocapitalization(.never)
                .focused(focusedField.projectedValue, equals: field.field.attributeType)
            }
                       
            Button("authenticator.signUp.button.createAccount".localized()) {
                Task {
                    await signUp()
                }
            }
            .buttonStyle(.primary)
            
            footerContent
        }
        .onSubmit {
            focusNextField()
        }
        .animation(options.contentAnimation, value: state.fields)
        .messageBanner($state.message)
        .keyboardIterableToolbar(fields: self)
        .onAppear {
            state.configure(with: signUpFields)
        }
        .onChange(of: state) { state in
            state.configure(with: signUpFields)
        }
    }

    /// Sets a custom error mapping function for the `AuthError`s that are displayed
    /// - Parameter errorTransform: A closure that takes an `AuthError` and returns a ``AuthenticatorError`` that will be displayed.
    public func errorMap(_ errorTransform: @escaping (AuthError) -> AuthenticatorError) -> Self {
        state.errorTransform = errorTransform
        return self
    }

    private var signUpFields: [SignUpField] {
        if let overriden = overridenSignUpFields {
            return overriden
        }

        return options.signUpFields
    }

    private func signUp() async {
        guard validators.validate() else {
            log.verbose("Some input validations failed")
            return
        }

        try? await state.signUp()
    }
}

// MARK: - KeyboardIterableFields
extension SignUpView {
    private var currentIndex: Int? {
        return state.fields.firstIndex(where: {
            $0.field.attributeType == focusedField.wrappedValue
        })
    }

    private func focusableField(beforeIndex index: Int) -> SignUpAttribute? {
        guard index > 0 else {
            return nil
        }

        let previousField = state.fields[index - 1].field
        if let baseField = previousField as? BaseSignUpField,
           baseField.inputType == .date {
            return focusableField(beforeIndex: index - 1)
        }

        return previousField.attributeType
    }

    private func focusableField(afterIndex index: Int) -> SignUpAttribute? {
        guard index < state.fields.count - 1 else {
            return nil
        }

        let nextField = state.fields[index + 1].field
        if let baseField = nextField as? BaseSignUpField,
           baseField.inputType == .date {
            return focusableField(afterIndex: index + 1)
        }

        return nextField.attributeType
    }

    func focusPreviousField() {
        guard let currentIndex = currentIndex else { return }
        focusedField.wrappedValue = focusableField(beforeIndex: currentIndex)
    }

    func focusNextField() {
        guard let currentIndex = currentIndex else { return }
        focusedField.wrappedValue = focusableField(afterIndex: currentIndex)
    }

    var hasPreviousField: Bool {
        guard let currentIndex = currentIndex else { return false }
        return focusableField(beforeIndex: currentIndex) != nil
    }

    var hasNextField: Bool {
        guard let currentIndex = currentIndex else { return false }
        return focusableField(afterIndex: currentIndex) != nil
    }
}

// MARK: - Validators
extension SignUpView {
    class Validators: ObservableObject {
        @ObservedObject private var state: SignUpState
        private var validators: [SignUpAttribute: Validator] = [:]

        init(state: SignUpState) {
            self.state = state
        }

        func validator(for field: SignUpField) -> Validator {
            if let existing = validators[field.attributeType] {
                return existing
            }

            let validator = Validator(
                using: {[weak self] value in
                    guard !value.isEmpty else {
                        return field.isRequired ? FieldValidators.required(value) : nil
                    }

                    if let validator = field.validator {
                        return validator(value)
                    }

                    guard let self = self else {
                        return nil
                    }

                    if case .password = field.attributeType {
                        let configuration = self.state.configuration.passwordProtectionSettings
                        return FieldValidators.password(
                            minLength: configuration.minLength,
                            characterPolicy: configuration.characterPolicy.asPasswordCharactersPolicy()
                        )(value)
                    } else if case .passwordConfirmation = field.attributeType, value != self.state.password {
                        return "authenticator.validator.field.newPassword.doesNotMatch".localized()
                    }

                    return nil
                }
            )
            validators[field.attributeType] = validator
            return validator
        }

        func validate() -> Bool {
            var isValid = true
            for customValidator in validators.values {
                isValid = customValidator.validate() && isValid
            }
            return isValid
        }
    }
}

/// Default header for the ``SignUpView``. It displays the view's title
public struct SignUpHeader: View {
    public init() {}
    public var body: some View {
        DefaultHeader(
            title: "authenticator.signUp.title".localized()
        )
    }
}

/// Default footer for the ``SignUpView``. It displays the "Back to Sign In" button
public struct SignUpFooter: View {
    @Environment(\.authenticatorState) private var authenticatorState

    public init() {}
    public var body: some View {
        Button("authenticator.signUp.button.backToSignIn".localized()) {
            authenticatorState.move(to: .signIn)
        }
        .buttonStyle(.link)
    }
}
