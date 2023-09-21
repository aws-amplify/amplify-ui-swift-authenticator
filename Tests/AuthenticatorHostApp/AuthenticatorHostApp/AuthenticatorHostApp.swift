//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

@main
struct AuthenticatorHostApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    init() {
        let factory = AuthCategoryConfigurationFactory.shared
        factory.setUserAtribute(.phoneNumber)
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure(AmplifyConfiguration(auth: factory.createConfiguration()))

            Amplify.Logging.logLevel = .warn
        } catch {
            print("Unable to configure Amplify \(error)")
        }
    }
}
