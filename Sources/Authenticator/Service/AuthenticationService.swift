//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import class Amplify.AuthCategory
import protocol Amplify.AmplifyError
import protocol Amplify.AuthCategoryBehavior
import enum Amplify.AuthError
import enum Amplify.AuthUserAttributeKey
import enum Amplify.AuthSignInStep
import Foundation
import SwiftUI

protocol AuthenticationService: AuthCategoryBehavior, AnyObject { }

extension Amplify.AuthCategory: AuthenticationService, ObservableObject {}
