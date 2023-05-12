//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

/// A message that is displayed in the Authenticator
public protocol AuthenticatorMessage {
    /// The message to display
    var content: String { get }
    /// The style in which this message is displayed
    var style: AuthenticatorMessageStyle { get }
}

/// The style used to display an ``AuthenticatorMessage``
public struct AuthenticatorMessageStyle: Equatable {
    private enum InternalStyle {
        case info
        case error
    }
    private var type: InternalStyle

    private init(type: InternalStyle) {
        self.type = type
    }

    /// Used to display Information messages
    public static let info: AuthenticatorMessageStyle = .init(type: .info)

    /// Used to display error messages
    public static let error: AuthenticatorMessageStyle = .init(type: .error)
}

extension AuthenticatorMessage where Self == AuthenticatorInformation {
    /// A simple info message
    /// - Parameter message: The message that will be displayed
    public static func info(message: String) -> Self {
        return AuthenticatorInformation(content: message)
    }
}

extension AuthenticatorMessage where Self == AuthenticatorError {
    /// A simple error message
    /// - Parameter message: The message that will be displayed
    public static func error(message: String) -> Self {
        return AuthenticatorError(content: message)
    }
}

/// Represent a message that displays normal information
public struct AuthenticatorInformation: AuthenticatorMessage {
    public let content: String
    public let style: AuthenticatorMessageStyle = .info
}

/// Represent a message that displays an error
public struct AuthenticatorError: LocalizedError, AuthenticatorMessage {
    public let content: String
    public let style: AuthenticatorMessageStyle = .error

    /// An unknown error.
    public static func unknown(from error: Error) -> Self {
        log.verbose("Creating an unknown AuthenticatorError")
        log.verbose(error)

        return AuthenticatorError(
            content: "authenticator.unknownError".localized()
        )
    }
}

extension AuthenticatorError: AuthenticatorLogging {}
