//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSCognitoAuthPlugin
import Foundation

// MARK: - String Localizable keys
extension String {
    /// en = "%@ (Optional)", argument being the field's name. E.g. "Username"
    static let field_label_optional = "authenticator.field.label.optional"

    /// en = "Search region"
    static let field_regionCodes_search = "authenticator.regionCodes.search"

    /// en = "Select a date"
    static let field_date_label = "authenticator.field.date.label"

    /// en = "Close"
    static let imageButton_close = "authenticator.imageButton.close"

    /// en = "Clear"
    static let imageButton_clear = "authenticator.imageButton.clear"

    /// en = "Open"
    static let imageButton_open = "authenticator.imageButton.open"

    /// en = "Show password"
    static let imageButton_showPassword = "authenticator.imageButton.showPassword"

    /// en = "Hide password"
    static let imageButton_hidePassword = "authenticator.imageButton.hidePassword"

    /// en = "Username"
    static let field_username_label = "authenticator.field.username.label"

    /// en = "Enter your username"
    static let field_username_placeholder = "authenticator.field.username.placeholder"

    /// en = "Password"
    static let field_password_label = "authenticator.field.password.label"

    /// en = "Enter your password"
    static let field_password_placeholder = "authenticator.field.password.placeholder"

    /// en = "Confirm password"
    static let field_confirmPassword_label = "authenticator.field.confirmPassword.label"

    /// en = "Re-enter your password"
    static let field_confirmPassword_placeholder = "authenticator.field.confirmPassword.placeholder"

    /// en = "Email"
    static let field_email_label = "authenticator.field.email.label"

    /// en = "Enter your email"
    static let field_email_placeholder = "authenticator.field.email.placeholder"

    /// en = "Phone number"
    static let field_phoneNumber_label = "authenticator.field.phoneNumber.label"

    /// en = "Enter your phone number"
    static let field_phoneNumber_placeholder = "authenticator.field.phoneNumber.placeholder"

    /// en = "Dialling code"
    static let field_diallingCode_label = "authenticator.field.diallingCode.label"

    /// en = "+"
    static let field_diallingCode_placeholder = "authenticator.field.diallingCode.placeholder"

    /// en = "Verification Code"
    static let field_code_label = "authenticator.field.code.label"

    /// en = "Enter your verification code"
    static let field_code_placeholder = "authenticator.field.code.placeholder"

    /// en = "New password"
    static let field_newPassword_label = "authenticator.field.newPassword.label"

    /// en = "Enter your new password"
    static let field_newPassword_placeholder = "authenticator.field.newPassword.placeholder"

    /// en = "Confirm password"
    static let field_confirmNewPassword_label = "authenticator.field.confirmNewPassword.label"

    /// en = "Re-enter your new password"
    static let field_confirmNewPassword_placeholder = "authenticator.field.confirmNewPassword.placeholder"

    /// en = "Address"
    static let field_address_label = "authenticator.field.address.label"

    /// en = "Enter your address"
    static let field_address_placeholder = "authenticator.field.address.placeholder"

    /// en = "Birth Date"
    static let field_birthDate_label = "authenticator.field.birthDate.label"

    /// en = "Enter your birth date"
    static let field_birthDate_placeholder = "authenticator.field.birthDate.placeholder"

    /// en = "Gender"
    static let field_gender_label = "authenticator.field.gender.label"

    /// en = "Enter your gender"
    static let field_gender_placeholder = "authenticator.field.gender.placeholder"

    /// en = "Given name"
    static let field_givenName_label = "authenticator.field.givenName.label"

    /// en = "Enter your given name"
    static let field_givenName_placeholder = "authenticator.field.givenName.placeholder"

    /// en = "Middle name"
    static let field_middleName_label = "authenticator.field.middleName.label"

    /// en = "Enter your middle name"
    static let field_middleName_placeholder = "authenticator.field.middleName.placeholder"

    /// en =  "Family name"
    static let field_familyName_label = "authenticator.field.familyName.label"

    /// en = "Enter your family name"
    static let field_familyName_placeholder = "authenticator.field.familyName.placeholder"

    /// en = "Name"
    static let field_name_label = "authenticator.field.name.label"

    /// en = "Enter your name"
    static let field_name_placeholder = "authenticator.field.name.placeholder"

    /// en = "Nickname"
    static let field_nickname_label = "authenticator.field.nickname.label"

    /// en = "Enter your nickname"
    static let field_nickname_placeholder = "authenticator.field.nickname.placeholder"

    /// en = "Preferred username"
    static let field_preferredUsername_label = "authenticator.field.preferredUsername.label"

    /// en =  "Enter your preferred username"
    static let field_preferredUsername_placeholder = "authenticator.field.preferredUsername.placeholder"

    /// en = "Profile"
    static let field_profile_label = "authenticator.field.profile.label"

    /// en = "Enter your profile"
    static let field_profile_placeholder = "authenticator.field.profile.placeholder"

    /// en = "Website"
    static let field_website_label = "authenticator.field.website.label"

    /// en = "Enter your website"
    static let field_website_placeholder = "authenticator.field.website.placeholder"

    /// en = "Sign In"
    static let signIn_title = "authenticator.signIn.title"

    /// en = "Forgot password?"
    static let signIn_button_forgotPassword = "authenticator.signIn.button.forgotPassword"

    /// en = "Sign In"
    static let signIn_button_signIn = "authenticator.signIn.button.signIn"

    /// en = "Create account"
    static let signIn_button_createAccount = "authenticator.signIn.button.createAccount"

    /// en = "Set a new password"
    static let confirmSignInWithNewPassword_title = "authenticator.confirmSignInWithNewPassword.title"

    /// en  = "Submit"
    static let confirmSignInWithNewPassword_button_submit = "authenticator.confirmSignInWithNewPassword.button.submit"

    /// en = "Enter your Sign In code"
    static let confirmSignInWithMFACode_title = "authenticator.confirmSignInWithMFACode.title"

    /// en = "Enter your Sign In code"
    static let confirmSignInWithCustomChallenge_title = "authenticator.confirmSignInWithCustomChallenge.title"

    /// en = "Submit"
    static let confirmSignInWithCode_button_submit = "authenticator.confirmSignInWithCode.button.submit"

    /// en = "Reset your password"
    static let resetPassword_title = "authenticator.resetPassword.title"

    /// en = "Send code"
    static let resetPassword_button_sendCode = "authenticator.resetPassword.button.sendCode"

    /// en = "Back to Sign In"
    static let resetPassword_button_backToSignIn = "authenticator.resetPassword.button.backToSignIn"

    /// en = "Reset your password"
    static let confirmResetPassword_title = "authenticator.confirmResetPassword.title"

    /// en = "Submit"
    static let confirmResetPassword_button_submit = "authenticator.confirmResetPassword.button.submit"

    /// en = "Back to Sign In"
    static let confirmResetPassword_button_backToSignIn = "authenticator.confirmResetPassword.button.backToSignIn"

    /// en = "Create Account"
    static let signUp_title = "Create Account";

    /// en = "Forgot password?"
    static let signUp_button_forgotPassword = "authenticator.signUp.button.forgotPassword"

    /// en = "Create account"
    static let signUp_button_createAccount = "authenticator.signUp.button.createAccount"

    /// en = "Back to Sign In"
    static let signUp_button_backToSignIn = "authenticator.signUp.button.backToSignIn"

    /// en = "Confirm your account"
    static let confirmSignUp_title = "authenticator.confirmSignUp.title"

    /// en = "Lost your code?"
    static let confirmSignUp_lostCode = "authenticator.confirmSignUp.lostCode"

    /// en = "Submit"
    static let confirmSignUp_button_submit = "authenticator.confirmSignUp.button.submit"

    /// en = "Send code"
    static let confirmSignUp_button_sendCode = "authenticator.confirmSignUp.button.sendCode"

    /// en = "Back to Sign In"
    static let confirmSignUp_button_backToSignIn = "authenticator.confirmSignUp.button.backToSignIn"

    /// en = "Account recovery requires verified contact information"
    static let verifyUser_title = "authenticator.verifyUser.title"

    /// en = "Verify"
    static let verifyUser_button_verify = "authenticator.verifyUser.button.verify"

    /// en = "Skip"
    static let verifyUser_button_skip = "authenticator.verifyUser.button.skip"

    /// en = "Confirm your %@", argument being the user's attribute that needs confirmation. E.g., "Email"
    static let confirmVerifyUser_title = "authenticator.confirmVerifyUser.title"

    /// en = "Verify"
    static let confirmVerifyUser_button_verify = "authenticator.confirmVerifyUser.button.verify"

    /// en ="Skip"
    static let confirmVerifyUser_button_skip = "authenticator.confirmVerifyUser.button.skip"

    /// en = "Field"
    static let validator_field = "authenticator.validator.field"

    /// en = "%@ must not be blank.", argument being the field's name. E.g. "Username"
    static let validator_field_required = "authenticator.validator.field.required"

    /// en = "%@ must not exceed %i characters", first agument being the field's name (e.g. "Username"), second argument being a number
    static let validator_field_maxLength = "authenticator.validator.field.maxLength"

    /// en = "%@ must not be after %@", first argument being the field's name (e.g. "Birthdate"), second argument being a formatted date.
    static let validator_field_date_maxDate = "authenticator.validator.field.date.maxDate"

    /// en = "%@ must not be before %@", first argument being the field's name (e.g. "Birthdate"), second argument being a formatted date.
    static let validator_field_date_minDate = "authenticator.validator.field.date.minDate"

    /// en = "%@ must include:", argument being the field's name. E.g. "Username"
    static let validator_field_conditions_title = "authenticator.validator.field.conditions.title"

    /// en = "\* at least %i characters", argument being a number
    static let validator_field_conditions_length = "authenticator.validator.field.conditions.length"

    /// en = "\* at least one number"
    static let validator_field_conditions_requiresNumbers = "authenticator.validator.field.conditions.requiresNumbers"

    /// en = "* at least one special character"
    static let validator_field_conditions_requiresSymbols = "authenticator.validator.field.conditions.requiresSymbols"

    /// en = "\* at least one lowercase letter"
    static let validator_field_conditions_requiresLowercase = "authenticator.validator.field.conditions.requiresLowercase"

    /// en = "\* at least one uppercase letter"
    static let validator_field_conditions_requiresUppercase = "authenticator.validator.field.conditions.requiresUppercase"

    /// en  = "Invalid email format"
    static let validator_field_email_format = "authenticator.validator.field.email.format"

    /// en = "Passwords do not match."
    static let validator_field_newPassword_doesNotMatch = "authenticator.validator.field.newPassword.doesNotMatch"

    /// en = "Invalid phone number"
    static let validator_field_phoneNumber_format = "authenticator.validator.field.phoneNumber.format"

    /// en = "A confirmation code has been sent to %@", argument being the destination where a code was sent. E.g. "axxx@axxx.com"
    static let banner_sendCode = "authenticator.banner.sendCode"

    /// en = "A confirmation code has been sent"
    static let banner_sencCodeGeneric = "authenticator.banner.sendCodeGeneric"

    /// en = "Something went wrong"
    static let authenticatorError_title = "authenticator.authenticatorError.title"

    /// en = "There is a configuration problem that is preventing the Authenticator from being displayed."
    static let authenticatorError_message = "authenticator.authenticatorError.message"

    /// en = "Incorrect username or password"
    static let authError_incorrectCredentials = "authenticator.authError.incorrectCredentials"

    /// en = "Sorry, something went wrong"
    static let unknownError = "authenticator.unknownError"

    /// en = "Done"
    static let keyboardToolbar_done = "authenticator.keyboardToolbar.Done"

    /// Builds a key using the provided cognito error so that it has the following format:
    /// `authenticator.cognitoError.[error]`
    ///
    /// `en` values for known errors:
    /// - codeDelivery = "Could not send confirmation code"
    /// - codeExpired = "Confirmation code has expired"
    /// - codeMismatch = "Incorrect confirmation code"
    /// - invalidPassword = "The provided password is not valid"
    /// - network = "Please check your connectivity"
    /// - usernameExists = "Username already exists"
    /// - userNotFound = "User not found"
    static func cognitoError(_ cognitoError: AWSCognitoAuthError) -> String {
        return "authenticator.cognitoError.\(cognitoError)"
    }
}
