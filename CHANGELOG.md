# Changelog

## 1.2.3 (2024-12-16)

### Bug Fixes
- **Theming**: Adding support for customizing the TextFields' input and placeholder foreground colours (#100)
- **Authenticator**: Avoiding signing out users when the token refresh fails due to no connectivity (#104)

## 1.2.2 (2024-11-26)

### Misc. Updates
- Updating code to support Amplify 2.45+

## 1.2.1 (2024-11-21)

### Misc. Updates
- Pinning the Amplify version up to 2.44.x

## 1.2.0 (2024-10-31)

### Feature
- **Authenticator**: Adding support for Email MFA (#96)

## 1.1.8 (2024-09-20)

### Bug Fixes
- **Authenticator**: Adding new error localizations for limits exceeded (#96)

## 1.1.7 (2024-09-13)

### Bug Fixes
- **Authenticator**: Allowing to only override the desired errors when invoking the errorMap functions (#93)

## 1.1.6 (2024-08-13)

### Bug Fixes
- **Authenticator**: Properly handling expired sessions when loading the component (#87)

## 1.1.5 (2024-07-02)

### Bug Fixes
- **Authenticator**: Setting corner radius according to the theme (#84)

## 1.1.4 (2024-06-07)

### Bug Fixes
- **Authenticator**: Showing the proper message when there's connectivity issues (#82)

### Misc. Updates
- Updating code to support Amplify 2.35+. (#82)

## 1.1.3 (2024-06-04)

### Bug Fixes
- **SignUp**: Sign in fails when user is auto confirmed after sign up (#72)

### Misc. Updates
- Pinning the Amplify version up to 2.34.x

## 1.1.2 (2024-04-26)

### Bug Fixes

- **AuthenticatorState**: Making `move(to:)` public (#66)
- **ConfirmSignUp**: Updating the state's `deliveryDetails` property when a new code is sent (#65)

## 1.1.1 (2024-03-11)

### Bug Fixes
- Fixing phone numbers containing special characters being rejected by Cognito (See [#56](https://github.com/aws-amplify/amplify-ui-swift-authenticator/pull/56))

### Misc. Updates
- Using the new `sendVerificationCode` API (See [#54](https://github.com/aws-amplify/amplify-ui-swift-authenticator/pull/54))

## 1.1.0 (2023-11-01)

### Features
- Adding TOTP support (See [#31](https://github.com/aws-amplify/amplify-ui-swift-authenticator/pull/43))

## 1.0.6 (2023-09-14)

### Misc. Updates
- Updating code to support Amplify 2.16+. However, **TOTP** workflows are **not** yet supported.

## 1.0.5 (2023-08-31)

### Bug Fixes
- Fixing required Sign Up attributes being displayed as optionals
- Fixing Sign Up fields not being populated when providing a `signUpContent`
- Fixing DatePicker being interactable while invisible, plus not displaying previous dates.

## 1.0.4 (2023-08-22)
### Bug Fixes
- Adding missing label when displaying a `.custom()` Sign Up field.

## 1.0.3 (2023-08-17)

### Bug Fixes
- Fixing wrong date format being submitted when displaying `SignUpField` of type `date` (See [#31](https://github.com/aws-amplify/amplify-ui-swift-authenticator/pull/31))

## 1.0.2 (2023-07-25)

### Misc. Updates
- Pinning the Amplify version up to 2.15.x

## 1.0.1 (2023-06-15)

### Bug Fixes
- Fixing issues with Sign Up fields (See [#25](https://github.com/aws-amplify/amplify-ui-swift-authenticator/pull/25)).
  - Removing duplicated fields in the array provided to `Authenticator.signUpFields(_:)`
  - Preventing fields of type `.phoneNumber` from saving an incomplete phone number if only the dialling code is set.
- Fixing Xcode 15 beta compilation error (See [#24](https://github.com/aws-amplify/amplify-ui-swift-authenticator/pull/24), thanks @RowbotNZ!)


## 1.0.0 (2023-05-24)

### Initial release of Amplify UI Authenticator for Swift UI

Amplify Authenticator provides a complete drop-in implementation of an authentication flow for your application using [Amplify Authentication](https://docs.amplify.aws/lib/auth/getting-started/q/platform/ios/).

More information on setting up and using the component is in the [documentation](https://ui.docs.amplify.aws/swift/connected-components/authenticator).
