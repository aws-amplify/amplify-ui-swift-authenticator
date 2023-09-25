//
//  ProcessArgument.swift
//  AuthenticatorHostApp
//
//  Created by Singh, Harshdeep on 2023-09-22.
//

import Foundation
@testable import Authenticator

enum ProcessArgument: Codable {
    
    case hidesSignUpButton(Bool)
    case initialStep(AuthenticatorInitialStep)
}
