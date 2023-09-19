//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension Bundle {
    // Name of the app
    var applicationName: String {
        if let localizedName = Bundle.main.infoDictionary?[kCFBundleLocalizationsKey as String] as? String {
            return localizedName
        }
        if let displayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return displayName
        }
        if let bundleName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String {
            return bundleName
        }
        return "AmplifyAuthenticator"
    }
}
